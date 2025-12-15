// lib/view/pay/paypage_multi.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/controller/store_controller.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/basket_detail.dart';

import 'package:xyz_project_01/util/message.dart';

import 'package:xyz_project_01/vm/database/goods_database.dart';
import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/vm/database/basket_database.dart';

import 'package:xyz_project_01/view/goods/g_map.dart';
import 'package:xyz_project_01/view/goods/g_tabbar.dart';

class PayPageMulti extends StatefulWidget {
  final String userid;
  final List<BasketDetail> items;
  const PayPageMulti({
    super.key,
    required this.userid,
    required this.items,
  });

  @override
  State<PayPageMulti> createState() => _PayPageMultiState();
}

class _PayPageMultiState extends State<PayPageMulti> {
  // 0: 간편결제, 1: 카드, 2: 매장
  int _selectedPaymentMethod = 0;

  final StoreController storeController = Get.find<StoreController>();
  final Message message = Message();

  final GoodsDatabase _goodsDB = GoodsDatabase();
  final PurchaseDatabase _purchaseDB = PurchaseDatabase();
  final BasketDatabase _basketDB = BasketDatabase();

  final NumberFormat _currencyFormatter = NumberFormat('#,###');
  final DateFormat _dbFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static const int _fee = 0;

  bool _isSubmitting = false;

  String _formatCurrency(num amount) => '${_currencyFormatter.format(amount.round())}원';

  int _payWayFromSelected(int selected) {
    if (selected == 0) return 1;
    if (selected == 1) return 2;
    return 3;
  }

  double get _subtotal {
    double total = 0;
    for (final d in widget.items) {
      final price = d.goods?.price ?? 0;
      total += price * d.basket.qty;
    }
    return total;
  }

  double get _totalAmount => _subtotal + _fee;

  @override
  Widget build(BuildContext context) {
    final store = storeController.selectedStore.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기(여러 상품)', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceivingStoreSelection(store),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _buildItemsSummary(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _buildPaymentMethod(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _buildOrderSummary(),
              ),
              const Padding(padding: EdgeInsets.only(top: 110)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCheckoutBar(context),
    );
  }


  Widget _buildReceivingStoreSelection(dynamic store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('수령매장 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: (store != null)
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['name'] as String,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${store['district']} · ${store['address']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('수령할 매장을 선택해 주세요.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ),
        ),

        ElevatedButton(
          onPressed: () => Get.to(() => GMap(userid: widget.userid)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  store == null ? '제품을 받을 매장을 선택하세요' : '수령 매장 변경하기',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSummary() {
    final totalQty = widget.items.fold<int>(0, (acc, d) => acc + d.basket.qty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('구매 내역 확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('총 ${widget.items.length}종 · $totalQty개', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: widget.items.map((d) {
              final g = d.goods;
              final price = g?.price ?? 0;
              final sum = price * d.basket.qty;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: (g?.mainimage != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(g!.mainimage!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g?.gname ?? d.basket.gname, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if ((g?.gengname ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(g!.gengname, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '옵션: ${d.basket.gsize} / ${d.basket.gcolor} · 수량: ${d.basket.qty}개',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('금액', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_formatCurrency(sum), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('결제 방법', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              _buildPaymentOption(title: '간편 결제', subtitle: '', value: 0),
              const Divider(),
              _buildPaymentOption(title: '신용카드', subtitle: '일시불 + 할부', value: 1),
              const Divider(),
              _buildPaymentOption(title: '매장에서 결제', subtitle: '현금 + 카드', value: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = value),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedPaymentMethod = v);
              },
              activeColor: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(title, style: const TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('최종 주문 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              _buildSummaryRow('구매가', _formatCurrency(_subtotal)),
              const Divider(height: 30, thickness: 1.5),
              _buildSummaryRow('총 결제금액', _formatCurrency(_totalAmount), isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.black : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: isTotal ? Colors.red : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (storeController.selectedStore.value == null) {
                    message.warning('매장 선택', '먼저 수령 매장을 선택해 주세요.');
                    return;
                  }
                  await _processMultiPaymentAndSave();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            disabledBackgroundColor: Colors.grey.shade400,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  '${_formatCurrency(_totalAmount)} 결제요청하기(1번)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // Functions ---------------------------

  Future<void> _processMultiPaymentAndSave() async {
    if (_isSubmitting) return;

    if (storeController.selectedStore.value == null) {
      message.warning('매장 선택', '수령 매장을 먼저 선택해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payWay = _payWayFromSelected(_selectedPaymentMethod);
      final now = DateTime.now();
      final dateString = _dbFormat.format(now);

      int success = 0;
      int fail = 0;

      final List<int> successBseqs = [];

      for (final item in widget.items) {
        final b = item.basket;

        // bseq 없으면 삭제도 못 하니 실패 처리
        if (b.bseq == null) {
          fail++;
          continue;
        }

        // gseq 확정
        final variant = await _goodsDB.getGoodsVariant(
          gname: b.gname,
          gsize: b.gsize,
          gcolor: b.gcolor,
        );

        if (variant == null || variant.gseq == null) {
          fail++;
          continue;
        }

        final price = variant.price;
        final itemFinalPrice = price * b.qty;

        final newPurchase = Purchase(
          pstatus: 2,
          pdate: dateString,
          pamount: b.qty,
          ppaydate: dateString,
          ppayprice: itemFinalPrice.toDouble(),
          ppayway: payWay,
          ppayamount: b.qty,
          pdiscount: 0.0,
          userid: widget.userid,
          gseq: variant.gseq,
          gsize: b.gsize,
          gcolor: b.gcolor,
        );

        final r = await _purchaseDB.insertPurchase(newPurchase);
        if (r > 0) {
          success++;
          successBseqs.add(b.bseq!);
        } else {
          fail++;
        }
      }

      // 성공한 장바구니 항목만 삭제
      if (successBseqs.isNotEmpty) {
        await _basketDB.deleteBasketByBseqList(successBseqs);
      }

      if (!mounted) return;

      if (success > 0) {
        Get.defaultDialog(
          title: '완료',
          middleText: '결제 요청이 등록되었습니다.\n(승인 후 재고가 차감됩니다)\n\n성공: $success건 / 실패: $fail건',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () => Get.offAll(() => GTabbar(userid: widget.userid)),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('OK'),
            ),
          ],
        );
      } else {
        message.error('실패', '결제 요청 등록에 실패했습니다.\n(성공 0건)');
      }
    } catch (e) {
      if (!mounted) return;
      message.error('오류', '결제 처리 중 오류 발생: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
