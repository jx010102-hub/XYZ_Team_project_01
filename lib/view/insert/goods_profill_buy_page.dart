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

import 'package:xyz_project_01/view/insert/refund_request_page.dart';

// UI용 상세 모델
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

// ListView용 Row 모델
enum _RowType { header, order, refund }

class _ListRow {
  final _RowType type;
  final String? header;
  final OrderDetail? order;
  final RefundDetail? refund;

  const _ListRow.header(this.header)
      : type = _RowType.header,
        order = null,
        refund = null;

  const _ListRow.order(this.order)
      : type = _RowType.order,
        header = null,
        refund = null;

  const _ListRow.refund(this.refund)
      : type = _RowType.refund,
        header = null,
        order = null;
}

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

  // 공용 유틸
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

  // 데이터 로드
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

  // 반품 요청 페이지 열기
  Future<void> _goRefundRequestPage(OrderDetail detail) async {
    final p = detail.purchase;
    if (p.pseq == null || p.pstatus != 4) {
      _info('알림', '수령 완료된 주문만 반품 요청이 가능합니다.');
      return;
    }

    final goodsName = detail.goods?.gname ?? '(상품 정보 없음)';
    final optionText = _optionText(p);

    final result = await Get.to<bool>(() => RefundRequestPage(
          pseq: p.pseq!,
          goodsName: goodsName,
          optionText: optionText,
        ));

    if (!mounted) return;

    if (result == true) {
      setState(() => _currentView = OrderView.refund);
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadAll();
    }
  }

  // 액션
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

  // 반품 완료 + 재고복원
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
                child: Text('정말 반품을 완료할까요?', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
                        child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
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

                            if (!mounted) return;

                            if (success) {
                              _success('완료', '반품이 완료되었습니다.');
                              await _loadAll();
                            } else {
                              _error('실패', '반품 처리 실패');
                            }
                          },
                          child: const Text('완료하기', style: TextStyle(fontWeight: FontWeight.bold)),
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
      barrierDismissible: false,
    );
  }

  // Build
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
                    ? _buildPurchaseViewList()
                    : _buildRefundViewList(),
          ),
        ],
      ),
    );
  }

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
          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 15),
        ),
      ),
    );
  }

  String _toDateKey(String dateTimeStr) {
    return dateTimeStr.split(' ')[0].replaceAll('-', '.');
  }

  List<_ListRow> _buildPurchaseRows(List<OrderDetail> items) {
    if (items.isEmpty) return const [];

    final Map<String, List<OrderDetail>> grouped = {};
    for (final d in items) {
      final key = _toDateKey(d.purchase.pdate);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(d);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final rows = <_ListRow>[];
    for (final date in dates) {
      rows.add(_ListRow.header(date));
      for (final d in grouped[date]!) {
        rows.add(_ListRow.order(d));
      }
    }
    return rows;
  }

  List<_ListRow> _buildRefundRows(List<RefundDetail> items) {
    if (items.isEmpty) return const [];

    final Map<String, List<RefundDetail>> grouped = {};
    for (final d in items) {
      final key = _toDateKey(d.refund.rdate);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(d);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final rows = <_ListRow>[];
    for (final date in dates) {
      rows.add(_ListRow.header(date));
      for (final d in grouped[date]!) {
        rows.add(_ListRow.refund(d));
      }
    }
    return rows;
  }

  Widget _buildPurchaseViewList() {
    final visible = _purchaseDetails;
    if (visible.isEmpty) {
      return Center(child: Text('$_currentUserId 님의 주문 내역이 없습니다.'));
    }

    final rows = _buildPurchaseRows(visible);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];

        if (row.type == _RowType.header) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                row.header ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return _buildOrderItemCard(row.order!);
      },
    );
  }

  Widget _buildRefundViewList() {
    final visible = _refundDetails;
    if (visible.isEmpty) {
      return Center(child: Text('$_currentUserId 님의 반품 내역이 없습니다.'));
    }

    final rows = _buildRefundRows(visible);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];

        if (row.type == _RowType.header) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                row.header ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return _buildRefundItemCard(row.refund!);
      },
    );
  }

  // 카드 UI 이하
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
                      ? Image.memory(
                          img,
                          fit: BoxFit.cover,
                          cacheWidth: 120,
                          cacheHeight: 120,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                        )
                      : const Center(
                          child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 40),
                        ),
                ),
              ),
            ),
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
                          height: 30,
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
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () => _goRefundRequestPage(detail),
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
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
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
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: img != null
                      ? Image.memory(
                          img,
                          fit: BoxFit.cover,
                          cacheWidth: 120,
                          cacheHeight: 120,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                        )
                      : Center(child: Text('반품', style: TextStyle(color: Colors.grey.shade500))),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                  if (engTitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(engTitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
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
                    child: Text('요청일: ${r.rdate.split(' ')[0]}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ),
                  if (r.rstatus == 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _completeRefundAndRestore(detail),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('반품 완료하기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
              child: Text(
                statusText,
                style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
