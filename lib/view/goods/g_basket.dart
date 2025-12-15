// lib/view/basket/g_basket.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/controller/store_controller.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/model/basket.dart';
import 'package:xyz_project_01/model/basket_detail.dart';
import 'package:xyz_project_01/util/message.dart';

import 'package:xyz_project_01/vm/database/basket_database.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

import 'package:xyz_project_01/view/pay/paypage.dart';
import 'package:xyz_project_01/view/pay/paypage_multi.dart';

class GBasket extends StatefulWidget {
  final String userid;
  const GBasket({super.key, required this.userid});

  @override
  State<GBasket> createState() => _GBasketState();
}

class _GBasketState extends State<GBasket> {
  final StoreController storeController = Get.find<StoreController>();
  final Message msg = Message();

  final BasketDatabase _basketDB = BasketDatabase();
  final GoodsDatabase _goodsDB = GoodsDatabase();

  final NumberFormat _currencyFormatter = NumberFormat('#,###');

  bool _isLoading = true;

  List<BasketDetail> _details = [];
  final Set<int> _checkedBseqs = {};

  double _totalPrice = 0;
  int _totalQuantity = 0;

  String _formatCurrency(num amount) => '${_currencyFormatter.format(amount.round())}원';

  @override
  void initState() {
    super.initState();
    _loadBasket();
  }

  Future<void> _loadBasket() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final list = await _basketDB.queryBasketByUser(widget.userid);

      final joined = <BasketDetail>[];
      for (final b in list) {
        final variant = await _goodsDB.getGoodsVariant(
          gname: b.gname,
          gsize: b.gsize,
          gcolor: b.gcolor,
        );
        joined.add(BasketDetail(basket: b, goods: variant));
      }

      if (!mounted) return;

      setState(() {
        _details = joined;
        _isLoading = false;

        final exist = joined.map((e) => e.basket.bseq).whereType<int>().toSet();
        _checkedBseqs.removeWhere((bseq) => !exist.contains(bseq));

        if (_checkedBseqs.isEmpty) {
          _checkedBseqs.addAll(exist);
        }

        _recalcTotals();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      msg.error('오류', '장바구니 로드 실패: $e');
    }
  }

  void _recalcTotals() {
    double total = 0;
    int qty = 0;

    for (final d in _details) {
      final bseq = d.basket.bseq;
      if (bseq == null) continue;
      if (!_checkedBseqs.contains(bseq)) continue;

      final price = d.goods?.price ?? 0;
      total += price * d.basket.qty;
      qty += d.basket.qty;
    }

    _totalPrice = total;
    _totalQuantity = qty;
  }

  int _findIndexByBseq(int bseq) {
    return _details.indexWhere((e) => e.basket.bseq == bseq);
  }

  Future<void> _updateQty(BasketDetail d, int change) async {
    final bseq = d.basket.bseq;
    if (bseq == null) return;

    final newQty = d.basket.qty + change;
    if (newQty < 1) return;

    try {
      final r = await _basketDB.updateBasketQty(bseq, newQty);
      if (r > 0) {
        if (!mounted) return;

        setState(() {
          final idx = _findIndexByBseq(bseq);
          if (idx != -1) {
            final old = _details[idx];

            final newBasket = Basket(
              bseq: old.basket.bseq,
              userid: old.basket.userid,
              gname: old.basket.gname,
              gsize: old.basket.gsize,
              gcolor: old.basket.gcolor,
              qty: newQty,
              createdAt: old.basket.createdAt,
            );

            _details[idx] = old.copyWith(basket: newBasket);
          }

          _recalcTotals();
        });
      }
    } catch (e) {
      msg.error('오류', '수량 변경 실패: $e');
    }
  }

  Future<void> _deleteItem(BasketDetail d) async {
    final bseq = d.basket.bseq;
    if (bseq == null) return;

    try {
      final r = await _basketDB.deleteBasket(bseq);
      if (r > 0) {
        msg.success('삭제', '장바구니 항목 삭제됨');
        await _loadBasket();
      } else {
        msg.error('실패', '삭제 실패');
      }
    } catch (e) {
      msg.error('오류', '삭제 중 오류: $e');
    }
  }

  void _toggleCheck(int bseq) {
    setState(() {
      if (_checkedBseqs.contains(bseq)) {
        _checkedBseqs.remove(bseq);
      } else {
        _checkedBseqs.add(bseq);
      }
      _recalcTotals();
    });
  }

  // 옵션변경
  void _openOptionSheet(BasketDetail d) async {
    final bseq = d.basket.bseq;
    if (bseq == null) return;

    final gname = d.basket.gname;

    List<Goods> options = [];
    try {
      options = await _goodsDB.getGoodsByName(gname);
    } catch (e) {
      msg.error('오류', '옵션 로드 실패: $e');
      return;
    }

    final sizes = options.map((e) => e.gsize).toSet().toList()..sort();
    final colors = options.map((e) => e.gcolor).toSet().toList()..sort();

    String tempSize = d.basket.gsize;
    String tempColor = d.basket.gcolor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheetSet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('옵션 변경', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(gname, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Text('사이즈', style: TextStyle(color: Colors.grey)),
                  ),

                  DropdownButton<String>(
                    value: tempSize,
                    isExpanded: true,
                    items: sizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      sheetSet(() => tempSize = v);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('색상', style: TextStyle(color: Colors.grey)),
                  ),

                  DropdownButton<String>(
                    value: tempColor,
                    isExpanded: true,
                    items: colors.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      sheetSet(() => tempColor = v);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          try {
                            final r = await _basketDB.updateBasketOption(
                              bseq: bseq,
                              gsize: tempSize,
                              gcolor: tempColor,
                            );

                            if (!mounted) return;

                            if (r > 0) {
                              Navigator.pop(context);
                              msg.success('완료', '옵션 변경 완료됨');
                              await _loadBasket();
                            } else {
                              msg.error('실패', '옵션 변경 실패');
                            }
                          } catch (e) {
                            msg.error('오류', '옵션 변경 오류: $e');
                          }
                        },
                        child: const Text('적용'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 바로주문(1개)
  void _goPaySingle(BasketDetail d) {
    final goods = d.goods;
    if (goods == null) {
      msg.error('오류', '상품 옵션을 찾을 수 없음');
      return;
    }

    Get.to(() => PayPage(
          goods: goods,
          selectedSize: d.basket.gsize,
          selectedColor: d.basket.gcolor,
          quantity: d.basket.qty,
          userid: widget.userid,
        ));
  }

  // 체크된 여러개 결제
  void _goPaySelected() {
    final selected = _details.where((d) {
      final bseq = d.basket.bseq;
      return bseq != null && _checkedBseqs.contains(bseq);
    }).toList();

    if (selected.isEmpty) {
      msg.info('안내', '구매할 상품을 체크해야 함');
      return;
    }

    Get.to(() => PayPageMulti(
          userid: widget.userid,
          items: selected,
        ));
  }

  Widget _thumb(Uint8List? bytes) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: bytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(bytes, fit: BoxFit.cover),
            )
          : const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildItem(BasketDetail d) {
    final b = d.basket;
    final bseq = b.bseq ?? -1;
    final checked = _checkedBseqs.contains(bseq);

    final goods = d.goods;
    final price = goods?.price ?? 0;
    final sum = price * b.qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _toggleCheck(bseq),
                    child: Icon(
                      checked ? Icons.check_box : Icons.check_box_outline_blank,
                      color: checked ? Colors.black : Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _thumb(goods?.mainimage),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goods?.gname ?? b.gname,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            goods?.gengname ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),

                          // (기존: SizedBox(height: 6))
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '옵션: ${b.gsize} / ${b.gcolor}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _deleteItem(d),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1, color: Colors.black12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: b.qty > 1 ? () => _updateQty(d, -1) : null,
                          color: b.qty > 1 ? Colors.black : Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text('${b.qty}', style: const TextStyle(fontSize: 16)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => _updateQty(d, 1),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('총 상품 금액', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _formatCurrency(sum),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _openOptionSheet(d),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('옵션변경'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: () => _goPaySingle(d),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('바로주문'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/xyz_logo.png', height: 70, width: 70, fit: BoxFit.contain),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details.isEmpty
              ? const Center(child: Text('장바구니가 비어있습니다.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._details.map(_buildItem),
                      const Padding(padding: EdgeInsets.only(bottom: 110)),
                    ],
                  ),
                ),
      bottomSheet: Obx(() {
        final store = storeController.selectedStore.value;

        _recalcTotals();

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _goPaySelected,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: const Color(0xFFE53935),
                  alignment: Alignment.center,
                  child: Text(
                    '${_formatCurrency(_totalPrice)} · 총 $_totalQuantity개 상품 구매하기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (store != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.store, color: Colors.black87, size: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store['name'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  '${store['district']} · ${store['address']}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () => msg.info('안내', '매장 변경은 기존 흐름대로 GMap 연결하면 됨'),
                        child: const Text('변경', style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
