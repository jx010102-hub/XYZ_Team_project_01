import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/util/message.dart';

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

  final Message msg = const Message();

  bool _isLoading = true;
  bool _isApproving = false;

  List<ReturnRequestDetail> _details = [];
  final Set<int> _selectedRseqs = {};

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  // Load pending refunds (rstatus=1)
  Future<void> _loadPending() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final pending = await _refundDB.queryPendingRefunds(); // rstatus=1
      final List<ReturnRequestDetail> temp = [];

      for (final r in pending) {
        Purchase? p;
        Goods? g;

        try {
          // Purchase 단건 조회 (rpseq == purchase.pseq)
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
    } catch (e) {
      if (!mounted) return;
      msg.error('오류', '반품 요청 목록을 불러오지 못했습니다: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Selection
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
      msg.info('안내', '승인할 반품 요청을 선택하세요');
      return;
    }

    setState(() => _isApproving = true);

    int success = 0;
    int fail = 0;

    try {
      final targets = _selectedRseqs.toList();
      for (final rseq in targets) {
        try {
          final r = await _refundDB.approveRefund(rseq);
          if (r > 0) {
            success++;
          } else {
            fail++;
          }
        } catch (_) {
          fail++;
        }
      }
      if (!mounted) return;

      if (success > 0) msg.success('완료', '반품 승인 완료됨 ($success건)');
      if (fail > 0) msg.warning('주의', '승인 실패/불가 ($fail건)');

      await _loadPending(); // 승인된 건들 목록에서 사라짐
    } catch (e) {
      if (!mounted) return;
      msg.error('오류', '승인 처리 중 오류: $e');
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  // ---------------- build ----------------
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
                        itemBuilder: (_, i) => _buildCard(_details[i]),
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
  } // build

  // ---------------- Functions ----------------
  Widget _buildCard(ReturnRequestDetail d) {
    final rseq = d.refund.rseq ?? -1;
    final checked = _selectedRseqs.contains(rseq);

    final goodsName = d.goods?.gname ?? '상품 정보 없음';
    final goodsEng = d.goods?.gengname ?? '';
    final option = (d.purchase == null)
        ? '-'
        : '${d.purchase!.gsize ?? ''} / ${d.purchase!.gcolor ?? ''}';

    final reqDate = d.refund.rdate;
    final orderNo = d.refund.rpseq; // 주문번호는 rpseq(=purchase.pseq)

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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '요청 일시: $reqDate',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            _thumb(d.goods?.mainimage),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
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
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '옵션: $option',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '주문번호: #$orderNo',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(Uint8List? bytes) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: (bytes != null)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(bytes, fit: BoxFit.cover),
            )
          : const Icon(Icons.image, color: Colors.grey),
    );
  }
}
