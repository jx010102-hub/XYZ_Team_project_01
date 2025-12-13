import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/model/goods.dart';

import 'package:xyz_project_01/util/message.dart';

import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/vm/database/refund_database.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

// ===============================
// UI용 상세 모델
// ===============================
class OrderDetail {
  final Purchase purchase;
  final Goods? goods;
  OrderDetail({required this.purchase, required this.goods});
}

class RefundDetail {
  final Refund refund;
  final Purchase? purchase;
  final Goods? goods;
  RefundDetail({required this.refund, required this.purchase, required this.goods});
}

enum OrderView { purchase, refund }

class GoodsProfillBuyPage extends StatefulWidget {
  final String userId;
  const GoodsProfillBuyPage({super.key, required this.userId});

  @override
  State<GoodsProfillBuyPage> createState() => _GoodsProfillBuyPageState();
}

class _GoodsProfillBuyPageState extends State<GoodsProfillBuyPage> {
  bool _isLoading = true;
  late String _currentUserId;

  OrderView _currentView = OrderView.purchase;

  final PurchaseDatabase _purchaseDB = PurchaseDatabase();
  final RefundDatabase _refundDB = RefundDatabase();
  final GoodsDatabase _goodsDB = GoodsDatabase();

  final Message _message = const Message();

  List<OrderDetail> _purchaseDetails = [];
  List<RefundDetail> _refundDetails = [];

  final Map<int, String> _purchaseStatusMap = const {
    1: '주문 요청',
    2: '결제 완료',
    3: '승인 완료',
    4: '수령 완료',
    5: '주문 취소됨',
  };

  final Map<int, String> _refundStatusMap = const {
    1: '반품 요청(대기)',
    2: '승인 완료',
    3: '반품 완료',
  };

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.userId;
    _loadAll();
  }

  // ===============================
  // 공용 유틸
  // ===============================
  void _info(String t, String m) => _message.info(t, m);
  void _success(String t, String m) => _message.success(t, m);
  void _error(String t, String m) => _message.error(t, m);

  void _closeDialogIfOpen() {
    if (Get.isDialogOpen ?? false) {
      Get.back(closeOverlays: true);
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.round())}원';
  }

  Color _purchaseStatusColor(int pstatus) {
    if (pstatus == 2) return Colors.blue;
    if (pstatus == 3) return Colors.blue.shade700;
    if (pstatus == 4) return Colors.green.shade700;
    if (pstatus == 5) return Colors.red.shade700;
    return Colors.black;
  }

  Color _refundStatusColor(int rstatus) {
    switch (rstatus) {
      case 1:
        return Colors.orange.shade700;
      case 2:
        return Colors.blue.shade700;
      case 3:
        return Colors.green.shade700;
      default:
        return Colors.black;
    }
  }

  String _optionText(Purchase p) {
    final s = p.gsize ?? '-';
    final c = p.gcolor ?? '-';
    return '색상: $c, 사이즈: $s';
  }

  // ===============================
  // 데이터 로드
  // ===============================
  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _loadUserRefunds();
      await _loadUserPurchases();
    } catch (e) {
      debugPrint('LOADALL ERROR: $e');
      _error('오류', '내역 로드 중 오류 발생');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPurchases() async {
    // ✅ 반품요청된 주문은 제외하고 가져오기
    final purchases = await _purchaseDB.queryPurchasesForUserExcludeRefunded(_currentUserId);

    final gseqSet = purchases.where((p) => p.gseq != null).map((p) => p.gseq!).toSet();
    final goodsList = await _goodsDB.getGoodsThumbByGseqList(gseqSet.toList());
    final goodsMap = {for (final g in goodsList) if (g.gseq != null) g.gseq!: g};

    final details = purchases
        .map((p) => OrderDetail(purchase: p, goods: (p.gseq != null) ? goodsMap[p.gseq!] : null))
        .toList();

    if (!mounted) return;
    setState(() => _purchaseDetails = details);
  }

  Future<void> _loadUserRefunds() async {
    final refunds = await _refundDB.queryRefundsByUserId(_currentUserId);

    final pseqSet = refunds.map((r) => r.rpseq).toSet();
    final purchaseList = await _purchaseDB.queryPurchasesByPseqList(pseqSet.toList());
    final purchaseMap = {for (final p in purchaseList) if (p.pseq != null) p.pseq!: p};

    final gseqSet = purchaseList.where((p) => p.gseq != null).map((p) => p.gseq!).toSet();
    final goodsList = await _goodsDB.getGoodsThumbByGseqList(gseqSet.toList());
    final goodsMap = {for (final g in goodsList) if (g.gseq != null) g.gseq!: g};

    final details = refunds.map((r) {
      final p = purchaseMap[r.rpseq];
      final g = (p != null && p.gseq != null) ? goodsMap[p.gseq!] : null;
      return RefundDetail(refund: r, purchase: p, goods: g);
    }).toList();

    if (!mounted) return;
    setState(() => _refundDetails = details);
  }

  // ===============================
  // 액션
  // ===============================
  Future<void> _markAsReceived(OrderDetail detail) async {
    final pseq = detail.purchase.pseq;
    if (pseq == null) return;

    try {
      final r = await _purchaseDB.updatePurchaseToReceived(pseq);
      if (r > 0) {
        _success('완료', '수령 완료 처리되었습니다.');
        await _loadAll();
      } else {
        _error('실패', '수령 완료 처리 실패');
      }
    } catch (e) {
      _error('오류', '수령 처리 중 오류');
    }
  }

  /// ✅ 반품 요청 다이얼로그 (기능 그대로)
  Future<void> _showRefundDialog(OrderDetail detail) async {
    final p = detail.purchase;

    if (p.pseq == null || p.pstatus != 4) {
      _info('알림', '수령 완료된 주문만 반품 요청이 가능합니다.');
      return;
    }

    final reasonController = TextEditingController();
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (_, setLocalState) {
          Future<void> submit() async {
            if (isSubmitting) return;

            final reason = reasonController.text.trim();
            if (reason.isEmpty) {
              _info('알림', '반품 사유를 입력해 주세요.');
              return;
            }

            setLocalState(() => isSubmitting = true);

            try {
              final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
              final newRefund = Refund(
                rdate: nowStr,
                rreason: reason,
                rstatus: 1,
                rpseq: p.pseq!,
              );

              final id = await _refundDB.insertRefund(newRefund);
              if (id <= 0) {
                setLocalState(() => isSubmitting = false);
                _error('실패', '반품 요청 등록 실패');
                return;
              }

              _closeDialogIfOpen();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                setState(() {
                  _purchaseDetails.removeWhere((d) => d.purchase.pseq == p.pseq);

                  _refundDetails.insert(
                    0,
                    RefundDetail(
                      refund: Refund(
                        rseq: id,
                        rdate: newRefund.rdate,
                        rreason: newRefund.rreason,
                        rstatus: newRefund.rstatus,
                        rpseq: newRefund.rpseq,
                      ),
                      purchase: p,
                      goods: detail.goods,
                    ),
                  );

                  _currentView = OrderView.refund;
                });

                _success('완료', '반품 요청이 등록되었습니다.');
              });
            } catch (e) {
              setLocalState(() => isSubmitting = false);
              _error('오류', '반품 요청 중 오류');
            }
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('반품 요청', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '사유를 입력하면 반품 요청이 접수됩니다.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: TextField(
                        controller: reasonController,
                        enabled: !isSubmitting,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '예) 사이즈가 맞지 않음',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting ? null : _closeDialogIfOpen,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // ✅ 더미 제거
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('요청하기', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    ).whenComplete(() => reasonController.dispose());
  }

  /// ✅ 반품 완료 + 재고복원 (기능 그대로)
  Future<void> _completeRefundAndRestore(RefundDetail detail) async {
    final rseq = detail.refund.rseq;
    final p = detail.purchase;

    if (rseq == null || p == null || p.gseq == null) {
      _error('오류', '정보가 올바르지 않습니다.');
      return;
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('반품 완료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '완료 시 재고가 복원되며 되돌릴 수 없습니다.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text(
                    '정말 반품을 완료할까요?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _closeDialogIfOpen,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // ✅ 더미 제거
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          _closeDialogIfOpen();

                          final success = await _refundDB.completeRefundWithStockRestore(
                            rseq: rseq,
                            gseq: p.gseq!,
                            restoreQty: p.pamount,
                          );

                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            if (!mounted) return;

                            if (success) {
                              _success('완료', '반품이 완료되었습니다.');
                              await _loadAll();
                            } else {
                              _error('실패', '반품 처리 실패');
                            }
                          });
                        },
                        child: const Text('완료하기', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ===============================
  // 화면
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '내역 관리',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildViewSwitcher(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentView == OrderView.purchase
                    ? _buildPurchaseView()
                    : _buildRefundView(),
          ),
        ],
      ),
    );
  }

  // ✅ 검색 UI 유지(기능 없음)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: '내역 검색',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildViewSwitcher() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildViewButton('주문내역', OrderView.purchase),
          _buildViewButton('반품내역 (${_refundDetails.length})', OrderView.refund),
        ],
      ),
    );
  }

  Widget _buildViewButton(String title, OrderView view) {
    final isSelected = _currentView == view;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: () => setState(() => _currentView = view),
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.black : Colors.grey.shade600,
          backgroundColor: isSelected ? Colors.grey.shade300 : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ===============================
  // 날짜 그룹 공용 빌더
  // ===============================
  Map<String, List<T>> _groupByDate<T>(List<T> items, String Function(T) dateKeyFn) {
    final Map<String, List<T>> grouped = {};
    for (final item in items) {
      final key = dateKeyFn(item);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    return grouped;
  }

  List<String> _sortedDateKeys(Map<String, List<dynamic>> grouped) {
    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys;
  }

  String _toDateKey(String dateTimeStr) {
    return dateTimeStr.split(' ')[0].replaceAll('-', '.');
  }

  // ===============================
  // 주문내역 View
  // ===============================
  Widget _buildPurchaseView() {
    final visible = _purchaseDetails;

    if (visible.isEmpty) {
      return Center(child: Text('$_currentUserId 님의 주문 내역이 없습니다.'));
    }

    final grouped = _groupByDate<OrderDetail>(visible, (d) => _toDateKey(d.purchase.pdate));
    final dates = _sortedDateKeys(grouped);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          for (final date in dates) ...[
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            for (final detail in grouped[date]!) _buildOrderItemCard(detail),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderDetail detail) {
    final p = detail.purchase;
    final g = detail.goods;

    final statusText = _purchaseStatusMap[p.pstatus] ?? '상태불명';
    final statusColor = _purchaseStatusColor(p.pstatus);

    final img = g?.mainimage;
    final title = g?.gname ?? '(상품 정보 없음)';
    final engTitle = g?.gengname ?? '';
    final option = _optionText(p);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: img != null
                      ? Image.memory(img, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160)
                      : const Center(
                          child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 40),
                        ),
                ),
              ),
            ),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (engTitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        engTitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(option, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${_formatCurrency(p.ppayprice)}  ${p.pamount}개',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),

            // 우측 상태/버튼
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusDisplay(statusText, statusColor),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      if (p.pstatus == 3)
                        SizedBox(
                          height: 30, // ✅ 버튼 높이 고정은 유지
                          child: ElevatedButton(
                            onPressed: () => _markAsReceived(detail),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text(
                              '수령하기',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (p.pstatus == 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: SizedBox(
                            height: 30, // ✅ 버튼 높이 고정은 유지
                            child: OutlinedButton(
                              onPressed: () => _showRefundDialog(detail),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text(
                                '반품 요청',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDisplay(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ===============================
  // 반품내역 View
  // ===============================
  Widget _buildRefundView() {
    final visible = _refundDetails;

    if (visible.isEmpty) {
      return Center(child: Text('$_currentUserId 님의 반품 내역이 없습니다.'));
    }

    final grouped = _groupByDate<RefundDetail>(visible, (d) => _toDateKey(d.refund.rdate));
    final dates = _sortedDateKeys(grouped);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          for (final date in dates) ...[
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            for (final detail in grouped[date]!) _buildRefundItemCard(detail),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundItemCard(RefundDetail detail) {
    final r = detail.refund;
    final p = detail.purchase;
    final g = detail.goods;

    final statusText = _refundStatusMap[r.rstatus] ?? '상태불명';
    final statusColor = _refundStatusColor(r.rstatus);

    final img = g?.mainimage;
    final title = g?.gname ?? '(상품 정보 없음)';
    final engTitle = g?.gengname ?? '';
    final option = (p == null) ? '옵션 정보 없음' : _optionText(p);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: img != null
                      ? Image.memory(img, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160)
                      : Center(child: Text('반품', style: TextStyle(color: Colors.grey.shade500))),
                ),
              ),
            ),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (engTitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        engTitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(option, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text('사유: ${r.rreason}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '요청일: ${r.rdate.split(' ')[0]}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ),
                  if (r.rstatus == 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 32, // ✅ 버튼 높이 고정은 유지
                        child: ElevatedButton(
                          onPressed: () => _completeRefundAndRestore(detail),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text(
                            '반품 완료하기',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 상태 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
              child: Text(
                statusText,
                style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
