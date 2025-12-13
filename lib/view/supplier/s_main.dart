import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/model/supply_order.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/supply_order_database.dart';

class SMain extends StatefulWidget {
  // ✅ sid/sname 유지 (기능 유지)
  final String sid;
  final String sname;

  const SMain({super.key, required this.sid, required this.sname});

  @override
  State<SMain> createState() => _SMainState();
}

class _SMainState extends State<SMain> {
  final SupplyOrderDatabase _orderDB = SupplyOrderDatabase();
  final Message message = Message();

  bool _isLoading = true;
  bool _isApproving = false;

  List<SupplyOrder> _pendingOrders = [];
  final Set<int> _selectedOseqs = {}; // 체크된 발주들

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final list = await _orderDB.queryPendingByManufacturer(widget.sname.trim());
      if (!mounted) return;

      setState(() {
        _pendingOrders = list;
        _selectedOseqs.clear();
      });
    } catch (e) {
      if (!mounted) return;
      message.error('오류', '발주 목록을 불러오지 못했습니다: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleSelect(int oseq) {
    setState(() {
      if (_selectedOseqs.contains(oseq)) {
        _selectedOseqs.remove(oseq);
      } else {
        _selectedOseqs.add(oseq);
      }
    });
  }

  Future<void> _approveSelected() async {
    if (_isApproving) return;

    if (_selectedOseqs.isEmpty) {
      message.info('안내', '승인할 요청을 선택해줘');
      return;
    }

    setState(() => _isApproving = true);

    final String apprdate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    int success = 0;

    try {
      // ✅ 선택된 발주들만 승인
      for (final oseq in _selectedOseqs) {
        final order = _pendingOrders.firstWhere((o) => o.oseq == oseq);
        final r = await _orderDB.approveOrderAndAddStock(
          oseq: oseq,
          gseq: order.gseq,
          qty: order.qty,
          apprdate: apprdate,
        );
        if (r > 0) success++;
      }

      if (!mounted) return;

      if (success > 0) {
        message.success('완료', '승인 완료됨 ($success건)');
      } else {
        message.error('실패', '승인 처리에 실패함');
      }

      await _fetchOrders();
    } catch (e) {
      if (!mounted) return;
      message.error('오류', '승인 처리 중 오류: $e');
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = _pendingOrders.length;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png',
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 칩 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('승인요청', style: TextStyle(fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.sname,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('전체 요청', style: TextStyle(fontSize: 14)),
                  ),
                  Row(
                    children: [
                      Text('총 $totalCount건', style: const TextStyle(fontSize: 14)),
                      IconButton(
                        onPressed: _isLoading ? null : _fetchOrders,
                        icon: const Icon(Icons.refresh),
                        tooltip: '새로고침',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 목록 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey.shade300,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (totalCount == 0
                          ? const Center(
                              child: Text(
                                "승인 요청이 없습니다.",
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: _pendingOrders.length,
                              itemBuilder: (context, index) {
                                final order = _pendingOrders[index];
                                final oseq = order.oseq;

                                final bool checked =
                                    (oseq != null) && _selectedOseqs.contains(oseq);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (oseq != null) _toggleSelect(oseq);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: checked ? Colors.black : Colors.grey.shade300,
                                          width: checked ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            checked
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: checked ? Colors.black : Colors.grey,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Expanded(
                                              child: _OrderInfo(order: order),
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
              ),
            ),

            // 승인 버튼
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: GestureDetector(
                onTap: (_isApproving || _pendingOrders.isEmpty) ? null : _approveSelected,
                child: Container(
                  width: 160,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (_isApproving || _pendingOrders.isEmpty)
                        ? Colors.grey.shade300
                        : Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _isApproving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _selectedOseqs.isEmpty ? "승인" : "승인 (${_selectedOseqs.length})",
                            style: TextStyle(
                              fontSize: 16,
                              color: (_isApproving || _pendingOrders.isEmpty)
                                  ? Colors.black87
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ 중복되는 카드 내부 텍스트 영역만 위젯으로 분리 (UI 동일, 코드만 정리)
class _OrderInfo extends StatelessWidget {
  final SupplyOrder order;
  const _OrderInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.gname,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Padding(padding: EdgeInsets.only(top: 4)),
        Text(
          '옵션: ${order.gsize} / ${order.gcolor}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const Padding(padding: EdgeInsets.only(top: 4)),
        Text(
          '수량: ${order.qty}개 · 제품코드: ${order.gseq}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const Padding(padding: EdgeInsets.only(top: 6)),
        Text(
          '요청일: ${order.reqdate}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
