import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/goods.dart';

import 'package:xyz_project_01/vm/database/refund_database.dart';
import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

class ReturnRequestDetail {
  final Refund refund;
  final Purchase? purchase;
  final Goods? goods;

  ReturnRequestDetail({
    required this.refund,
    required this.purchase,
    required this.goods,
  });
}

class AReturnRequest extends StatefulWidget {
  const AReturnRequest({super.key});

  @override
  State<AReturnRequest> createState() => _AReturnRequestState();
}

class _AReturnRequestState extends State<AReturnRequest> {
  final RefundDatabase _refundDB = RefundDatabase();
  final PurchaseDatabase _purchaseDB = PurchaseDatabase();
  final GoodsDatabase _goodsDB = GoodsDatabase();

  bool _isLoading = true;
  bool _isApproving = false;

  List<ReturnRequestDetail> _details = [];
  final Set<int> _selectedRseqs = {};

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);

    try {
      final pending = await _refundDB.queryPendingRefunds(); // ✅ rstatus=1만
      final List<ReturnRequestDetail> temp = [];

      for (final r in pending) {
        Purchase? p;
        Goods? g;

        try {
          // ✅ 수정 1) PurchaseDatabase의 단건조회 함수 사용
          p = await _purchaseDB.queryPurchaseByPseq(r.rpseq);

          if (p != null && p.gseq != null) {
            g = await _goodsDB.getGoodsByGseq(p.gseq!);
          }
        } catch (_) {
          p = null;
          g = null;
        }

        temp.add(ReturnRequestDetail(refund: r, purchase: p, goods: g));
      }

      if (!mounted) return;
      setState(() {
        _details = temp;
        _selectedRseqs.clear();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggle(int rseq) {
    setState(() {
      if (_selectedRseqs.contains(rseq)) {
        _selectedRseqs.remove(rseq);
      } else {
        _selectedRseqs.add(rseq);
      }
    });
  }

  Future<void> _approveSelected() async {
    if (_isApproving) return;

    if (_selectedRseqs.isEmpty) {
      Get.snackbar(
        '안내',
        '승인할 반품 요청을 선택해줘',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isApproving = true);

    int success = 0;
    try {
      // ✅ Set은 순회 중 변경되면 위험할 수 있어서 toList()로 고정
      final targets = _selectedRseqs.toList();

      for (final rseq in targets) {
        // ✅ 수정 2) approveRefund는 rstatus=1인 것만 2로 바꿈 (0이면 이미 승인됐거나 없음)
        final r = await _refundDB.approveRefund(rseq);
        if (r > 0) success++;
      }

      if (!mounted) return;

      Get.snackbar(
        '완료',
        '반품 승인 완료됨 ($success건)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await _loadPending(); // ✅ 승인된 건들은 여기서 사라짐
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        '오류',
        '승인 처리 중 오류: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _details.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('반품 요청', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadPending,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('처리 대기', style: TextStyle(fontSize: 14)),
                Text('총 $totalCount건', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (totalCount == 0
                    ? const Center(child: Text('승인 대기 중인 반품 요청이 없습니다.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _details.length,
                        itemBuilder: (_, i) {
                          final d = _details[i];
                          final rseq = d.refund.rseq ?? -1;
                          final checked = _selectedRseqs.contains(rseq);

                          final goodsName = d.goods?.gname ?? '상품 정보 없음';
                          final goodsEng = d.goods?.gengname ?? '';
                          final option = (d.purchase == null)
                              ? ''
                              : '${d.purchase!.gsize ?? ''} / ${d.purchase!.gcolor ?? ''}';
                          final reqDate = d.refund.rdate;

                          // ✅ 주문번호는 rpseq(=purchase.pseq)
                          final orderNo = d.refund.rpseq;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                if (rseq > 0) _toggle(rseq);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: checked ? Colors.black : Colors.grey.shade300,
                                    width: checked ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      checked ? Icons.check_box : Icons.check_box_outline_blank,
                                      color: checked ? Colors.black : Colors.grey,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '요청 일시: $reqDate',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: (d.goods?.mainimage != null)
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.memory(
                                                          d.goods!.mainimage!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : const Icon(Icons.image, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      goodsName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (goodsEng.isNotEmpty)
                                                      Text(
                                                        goodsEng,
                                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '옵션: $option',
                                                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '주문번호: #$orderNo',
                                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isApproving || _details.isEmpty) ? null : _approveSelected,
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _selectedRseqs.isEmpty ? '승인하기' : '승인하기 (${_selectedRseqs.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
