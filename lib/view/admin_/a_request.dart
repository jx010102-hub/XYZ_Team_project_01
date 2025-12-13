// lib/view/approval/a_request.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/goods.dart';
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

  List<PurchaseRequestDetail> _requestDetails = [];
  bool _isLoading = true;
  bool _isApproving = false;

  // ✅ 선택 승인용
  final Set<int> _selectedPseqs = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // ✅ Snackbar는 전부 TOP으로 통일
  void _snack(String title, String msg,
      {Color? bg, Color? textColor = Colors.white}) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg ?? Colors.black,
      colorText: textColor,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final pending = await _purchaseDB.queryPendingPurchases(); // pstatus=2
      final List<PurchaseRequestDetail> joined = [];

      for (final p in pending) {
        Goods? goods;
        int stock = 0;

        // debugPrint('[PENDING] pseq=${p.pseq}, gseq=${p.gseq}, userid=${p.userid}, amount=${p.pamount}');
        if (p.gseq != null) {
          goods = await _goodsDB.getGoodsByGseq(p.gseq!);
          stock = goods?.gsumamount ?? 0;

          // debugPrint('[GOODS] found=${goods != null}, name=${goods?.gname}, stock=${goods?.gsumamount}, imgLen=${goods?.mainimage?.length}');
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

        // ✅ 목록이 바뀌면 선택된 pseq 중 존재하지 않는 것은 제거
        final existPseqs = joined
            .map((e) => e.purchase.pseq)
            .where((v) => v != null)
            .map((v) => v!)
            .toSet();
        _selectedPseqs.removeWhere((pseq) => !existPseqs.contains(pseq));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _snack('오류', '결제 요청 목록을 불러오지 못했습니다: $e', bg: Colors.red);
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

  /// ✅ 단건 승인(기존 로직 유지) - 내부에서 재고 차감 → pstatus=3
  Future<bool> _approveOneInternal(PurchaseRequestDetail detail) async {
    final p = detail.purchase;
    final pseq = p.pseq;

    if (pseq == null) {
      _snack('오류', 'pseq가 없습니다.', bg: Colors.red);
      return false;
    }
    if (detail.goods == null || detail.goods!.gseq == null) {
      _snack('실패', '상품 정보를 찾을 수 없습니다.', bg: Colors.red);
      return false;
    }
    if (!detail.isStockSufficient) {
      _snack('실패', '재고 부족 (${detail.currentStock} < ${p.pamount})', bg: Colors.red);
      return false;
    }

    // 1) 재고 차감
    final goodsUpdate = await _goodsDB.updateGoodsQuantity(
      gseq: detail.goods!.gseq!,
      quantityChange: -p.pamount,
    );
    if (goodsUpdate <= 0) {
      _snack('실패', '재고 차감 실패', bg: Colors.red);
      return false;
    }

    // 2) 승인 처리: pstatus=3
    final statusUpdate = await _purchaseDB.updatePurchaseToApproved(pseq);
    if (statusUpdate <= 0) {
      _snack('실패', '주문 상태 변경 실패(pstatus=3)', bg: Colors.red);
      return false;
    }

    return true;
  }

  /// ✅ 선택 승인 (여러 개 한번에)
  Future<void> _approveSelected() async {
    if (_isApproving) return;

    if (_selectedPseqs.isEmpty) {
      _snack('안내', '승인할 결제 요청을 선택해줘', bg: Colors.black);
      return;
    }

    setState(() => _isApproving = true);

    int success = 0;
    int fail = 0;

    try {
      final targets = _selectedPseqs.toList();

      // ✅ pseq -> detail 빠르게 찾기 위해 map 구성
      final Map<int, PurchaseRequestDetail> mapByPseq = {
        for (final d in _requestDetails)
          if (d.purchase.pseq != null) d.purchase.pseq!: d
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

      if (success > 0) {
        _snack('완료', '승인 완료됨 ($success건)', bg: Colors.green.shade700);
      }
      if (fail > 0) {
        _snack('주의', '승인 실패/불가 ($fail건)', bg: Colors.orange.shade700);
      }

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
      _snack('오류', '승인 처리 중 오류: $e', bg: Colors.red);
    }
  }

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
                        itemBuilder: (context, index) => _buildCard(_requestDetails[index]),
                      ),
          ),

          // ✅ 하단: 선택 승인 버튼 (반품 승인 페이지처럼)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isApproving || _requestDetails.isEmpty) ? null : _approveSelected,
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
                        _selectedPseqs.isEmpty ? '승인하기' : '승인하기 (${_selectedPseqs.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(PurchaseRequestDetail detail) {
    final p = detail.purchase;
    final g = detail.goods;

    final pseq = p.pseq ?? -1;
    final checked = _selectedPseqs.contains(pseq);

    final title = g == null ? '상품 정보 없음' : g.gname;
    final option = '옵션: ${p.gsize ?? "-"} / ${p.gcolor ?? "-"}';
    final qty = '수량: ${p.pamount}개';
    final user = '구매자: ${p.userid}';
    final stock = '재고: ${detail.currentStock}개';
    final statusText = detail.isStockSufficient ? '재고 충분' : '재고 부족';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          if (pseq > 0) _toggleSelect(pseq);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 체크 + 주문번호/요청일
              Row(
                children: [
                  Icon(
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: checked ? Colors.black : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '주문번호 #${p.pseq} · 요청일 ${p.pdate}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (g?.mainimage != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              g!.mainimage!,
                              fit: BoxFit.cover,
                              cacheWidth: 128,
                              cacheHeight: 128,
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(option, style: const TextStyle(color: Colors.black54)),
                        Text(qty, style: const TextStyle(color: Colors.black54)),
                        Text(user, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text(
                          '$stock · $statusText',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: detail.isStockSufficient ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // (선택) 단건 승인 버튼을 유지하고 싶으면 여기 주석 해제
              // const SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     ElevatedButton(
              //       onPressed: (_isApproving || !detail.isStockSufficient || g == null)
              //           ? null
              //           : () async {
              //               setState(() => _isApproving = true);
              //               final ok = await _approveOneInternal(detail);
              //               if (mounted) setState(() => _isApproving = false);
              //               if (ok) {
              //                 _snack('성공', '승인 완료 (재고 차감 + 상태 3)', bg: Colors.green.shade700);
              //                 await _loadRequests();
              //               }
              //             },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.black,
              //         foregroundColor: Colors.white,
              //       ),
              //       child: Text(_isApproving ? '처리 중...' : '단건 승인'),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
