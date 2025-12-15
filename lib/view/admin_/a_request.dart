import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

class PurchaseRequestDetail {
  final Purchase purchase;
  final Goods? goods;
  final int currentStock;
  final bool isStockSufficient;

  PurchaseRequestDetail({
    required this.purchase,
    required this.goods,
    required this.currentStock,
    required this.isStockSufficient,
  });
}

class ARequst extends StatefulWidget {
  const ARequst({super.key});

  @override
  State<ARequst> createState() => _ARequstState();
}

class _ARequstState extends State<ARequst> {
  final PurchaseDatabase _purchaseDB = PurchaseDatabase();
  final GoodsDatabase _goodsDB = GoodsDatabase();

  final Message msg = const Message();

  List<PurchaseRequestDetail> _requestDetails = [];
  final Set<int> _selectedPseqs = {};

  bool _isLoading = true;
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final pending = await _purchaseDB.queryPendingPurchases();

      final Map<int, Goods?> goodsCache = {};
      final List<PurchaseRequestDetail> joined = [];

      for (final p in pending) {
        Goods? goods;
        int stock = 0;

        final gseq = p.gseq;
        if (gseq != null) {
          goodsCache[gseq] ??= await _goodsDB.getGoodsByGseq(gseq);
          goods = goodsCache[gseq];
          stock = goods?.gsumamount ?? 0;
        }

        joined.add(
          PurchaseRequestDetail(
            purchase: p,
            goods: goods,
            currentStock: stock,
            isStockSufficient: stock >= p.pamount,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _requestDetails = joined;
        _isLoading = false;

        final existPseqs = joined
            .map((e) => e.purchase.pseq)
            .whereType<int>()
            .toSet();
        _selectedPseqs.removeWhere((pseq) => !existPseqs.contains(pseq));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      msg.error('오류', '결제 요청 목록을 불러오지 못했습니다: $e');
    }
  }

  void _toggleSelect(int pseq) {
    setState(() {
      if (_selectedPseqs.contains(pseq)) {
        _selectedPseqs.remove(pseq);
      } else {
        _selectedPseqs.add(pseq);
      }
    });
  }

  Future<bool> _approveOneInternal(PurchaseRequestDetail detail) async {
    final p = detail.purchase;
    final pseq = p.pseq;

    if (pseq == null) {
      msg.error('오류', '상품 정보가 없습니다.');
      return false;
    }

    final goods = detail.goods;
    final gseq = goods?.gseq;

    if (goods == null || gseq == null) {
      msg.error('실패', '상품 정보를 찾을 수 없습니다.');
      return false;
    }

    if (!detail.isStockSufficient) {
      msg.error('실패', '재고 부족 (${detail.currentStock} < ${p.pamount})');
      return false;
    }

    // 재고 차감
    final goodsUpdate = await _goodsDB.updateGoodsQuantity(
      gseq: gseq,
      quantityChange: -p.pamount,
    );
    if (goodsUpdate <= 0) {
      msg.error('실패', '재고 차감 실패');
      return false;
    }

    // 승인 처리(pstatus=3)
    final statusUpdate = await _purchaseDB.updatePurchaseToApproved(pseq);
    if (statusUpdate <= 0) {
      msg.error('실패', '승인 실패');
      return false;
    }

    return true;
  }

  Future<void> _approveSelected() async {
    if (_isApproving) return;

    if (_selectedPseqs.isEmpty) {
      msg.info('안내', '승인할 결제 요청을 선택하세요');
      return;
    }

    setState(() => _isApproving = true);

    int success = 0;
    int fail = 0;

    try {
      final targets = _selectedPseqs.toList();

      final Map<int, PurchaseRequestDetail> mapByPseq = {
        for (final d in _requestDetails)
          if (d.purchase.pseq != null) d.purchase.pseq!: d,
      };

      for (final pseq in targets) {
        final detail = mapByPseq[pseq];
        if (detail == null) {
          fail++;
          continue;
        }

        try {
          final ok = await _approveOneInternal(detail);
          if (ok) {
            success++;
          } else {
            fail++;
          }
        } catch (_) {
          fail++;
        }
      }

      if (!mounted) return;

      if (success > 0) msg.success('완료', '승인 완료됨 ($success건)');
      if (fail > 0) msg.warning('주의', '승인 실패/불가 ($fail건)');

      await _loadRequests();

      if (mounted) {
        setState(() {
          _selectedPseqs.clear();
          _isApproving = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApproving = false);
      msg.error('오류', '승인 처리 중 오류: $e');
    }
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    final totalCount = _requestDetails.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 요청 승인', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('승인 대기(pstatus=2)', style: TextStyle(fontSize: 14)),
                Text('총 $totalCount건', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requestDetails.isEmpty
                    ? const Center(child: Text('승인 대기(pstatus=2) 요청이 없습니다.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _requestDetails.length,
                        itemBuilder: (context, index) =>
                            _buildCard(_requestDetails[index]),
                      ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isApproving || _requestDetails.isEmpty)
                    ? null
                    : _approveSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isApproving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _selectedPseqs.isEmpty
                            ? '승인하기'
                            : '승인하기 (${_selectedPseqs.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Functions ----------------
  Widget _buildCard(PurchaseRequestDetail detail) {
    final p = detail.purchase;
    final g = detail.goods;

    final pseq = p.pseq ?? -1;
    final checked = _selectedPseqs.contains(pseq);

    final title = g?.gname ?? '상품 정보 없음';
    final option = '옵션: ${p.gsize ?? "-"} / ${p.gcolor ?? "-"}';
    final qty = '수량: ${p.pamount}개';
    final user = '구매자: ${p.userid}';
    final stockText = '재고: ${detail.currentStock}개';
    final statusText = detail.isStockSufficient ? '재고 충분' : '재고 부족';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          if (pseq > 0) _toggleSelect(pseq);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: checked ? Colors.black : Colors.grey.shade300,
              width: checked ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: checked ? Colors.black : Colors.grey,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '주문번호 #${p.pseq} · 요청일 ${p.pdate}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _thumb(g?.mainimage),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                option,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                            Text(qty, style: const TextStyle(color: Colors.black54)),
                            Text(user, style: const TextStyle(color: Colors.black54)),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '$stockText · $statusText',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: detail.isStockSufficient
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _thumb(Uint8List? bytes) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: (bytes != null)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                cacheWidth: 128,
                cacheHeight: 128,
              ),
            )
          : const Icon(Icons.image, color: Colors.grey),
    );
  }
}
