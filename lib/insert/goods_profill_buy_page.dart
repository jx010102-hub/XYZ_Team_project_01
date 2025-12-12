// lib/goods/goods_profill_buy_page.dart (주문 취소 기능 추가)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/vm/database/refund_database.dart';
// ⭐️ 재고 관리를 위해 GoodsDatabase를 사용해야 함 (임포트 필요)
import 'package:xyz_project_01/vm/database/goods_database.dart'; 
import 'package:intl/intl.dart'; 


// ⭐️ UI 헬퍼 클래스 (Purchase 기반)
class OrderDetail {
  final Purchase purchase;
  final String itemName; // 상품명
  final String itemOptions; // 색상/사이즈 정보
  final String itemImageUrl;
  // ⭐️ 상품 재고 관리를 위한 Goods ID 임시 필드 (Goods 모델과 연결 시 필요)
  final int gseq; 

  OrderDetail({
    required this.purchase,
    required this.itemName,
    required this.itemOptions, // ⭐️ 옵션 필드 추가
    required this.itemImageUrl,
    required this.gseq, // ⭐️ 상품 ID 추가
  });
}

// ⭐️ UI 헬퍼 클래스 (Refund 기반)
class RefundDetail {
  final Refund refund;
  final String itemName; 

  RefundDetail({
    required this.refund,
    this.itemName = '반품 상품 정보 로딩 중',
  });
}

// ⭐️ 현재 선택된 뷰를 위한 Enum
enum OrderView { purchase, refund }

class GoodsProfillBuyPage extends StatefulWidget {
  final String userId; 
  
  const GoodsProfillBuyPage({super.key, required this.userId}); 

  @override
  State<GoodsProfillBuyPage> createState() =>
      _GoodsProfillBuyPageState();
}

class _GoodsProfillBuyPageState
    extends State<GoodsProfillBuyPage> {
  
  late TextEditingController _searchController;
  
  // 데이터 리스트
  List<OrderDetail> _purchaseDetails = []; 
  List<RefundDetail> _refundDetails = []; 
  
  bool _isLoading = true;
  late String _currentUserId; 
  
  // 주문 상태 맵 (5: 주문 취소됨 추가)
  final Map<int, String> _purchaseStatusMap = {
    1: '주문 요청', 
    2: '결제 완료', 
    3: '출고 준비', 
    4: '수령 완료',
    5: '주문 취소됨', // ⭐️ 주문 취소 상태 추가
  };
  
  // 반품 상태 맵
  final Map<int, String> _refundStatusMap = {
    1: '반품 요청(대기)', 
    2: '승인 완료', 
    3: '반품 완료'
  };

  // 상태 변수 및 DB 핸들러 인스턴스
  OrderView _currentView = OrderView.purchase;
  final PurchaseDatabase _purchaseDB = PurchaseDatabase();
  final RefundDatabase _refundDB = RefundDatabase();
  final GoodsDatabase _goodsDB = GoodsDatabase(); // ⭐️ Goods DB 핸들러 추가


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _currentUserId = widget.userId; 
    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadUserRefunds(); 
    await _loadUserPurchases();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _loadUserPurchases() async {
    List<Purchase> purchases = await _purchaseDB.queryPurchaseByUserId(_currentUserId); 
    
    // 이미 반품 요청된 주문(rpseq)의 PSEQ 목록을 만듭니다.
    final Set<int> refundedPSeqs = _refundDetails.map((r) => r.refund.rpseq).toSet();
    
    // 반품되지 않은 주문만 필터링하고 OrderDetail로 구성
    List<OrderDetail> details = purchases
        .where((p) => !refundedPSeqs.contains(p.pseq))
        .map((p) {
      return OrderDetail(
        purchase: p,
        // ⭐️ 상품명, 옵션 임시값 설정 (실제로는 DB 조인이 필요)
        itemName: '나이키 에어포스 1 디테일', 
        itemOptions: '색상: 화이트/블랙, 사이즈: 270', 
        itemImageUrl: 'images/shoe_brown.png', 
        gseq: 1, // ⭐️ 임시 상품 ID 설정 (DB에서 가져와야 함)
      );
    }).toList();

    if (mounted) {
      setState(() {
        _purchaseDetails = details;
      });
    }
  }

  // 사용자 반품 내역 로드
  Future<void> _loadUserRefunds() async {
    List<Refund> refunds = await _refundDB.queryRefundsByUserId(_currentUserId); 
    
    List<RefundDetail> details = refunds.map((r) => RefundDetail(refund: r, itemName: '반품 상품 PSEQ: ${r.rpseq}')).toList();
    
    if (mounted) {
      setState(() {
        _refundDetails = details;
      });
    }
  }

  // ⭐️⭐️⭐️ 주문 취소 처리 함수 (재고 복원 포함) ⭐️⭐️⭐️
  Future<void> _cancelOrder(OrderDetail detail) async {
    final pseq = detail.purchase.pseq!;
    final quantity = detail.purchase.pamount;
    final gseq = detail.gseq; // 취소할 상품의 ID

    try {
      // 1. 주문 상태를 취소(5)로 업데이트
      int statusResult = await _purchaseDB.updatePurchaseStatus(pseq, 5);

      // 2. 재고 복원 (수량을 양수로 전달)
      int goodsResult = await _goodsDB.updateGoodsQuantity(
        gseq: gseq,
        quantityChange: quantity,
      );

      if (statusResult > 0 && goodsResult > 0) {
        Get.snackbar('성공', '주문 취소가 완료되었으며 재고 ${quantity}개가 복원되었습니다.', snackPosition: SnackPosition.BOTTOM); 
        await _loadAllData(); // 데이터 새로고침
      } else {
        throw Exception('DB 업데이트 실패 (주문 상태 또는 재고)');
      }
    } catch (e) {
      Get.snackbar('오류', '주문 취소 처리 중 문제가 발생했습니다: $e', snackPosition: SnackPosition.BOTTOM); 
    }
  }

  // 반품 요청 처리 함수 (기존과 동일)
  void _requestRefund(OrderDetail detail) async {
    if (detail.purchase.pstatus != 4) {
        Get.snackbar('알림', '수령 완료된 주문만 반품 요청이 가능합니다.', snackPosition: SnackPosition.BOTTOM);
        return;
    }
    
    final pseq = detail.purchase.pseq!;
    const String reason = "고객 요청에 의한 단순 변심"; 

    final newRefund = Refund(
      rdate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      rreason: reason,
      rstatus: 1, // 반품 요청, 승인 대기
      rpseq: pseq,
    );

    try {
      final newRseq = await _refundDB.insertRefund(newRefund);

      if (newRseq > 0) {
        Get.snackbar('성공', '반품 요청이 완료되었습니다.', snackPosition: SnackPosition.BOTTOM); 
        await _loadAllData();
        
        setState(() {
          _currentView = OrderView.refund; 
        });
      } else {
        throw Exception('DB 삽입 실패');
      }
    } catch (e) {
      Get.snackbar('오류', '반품 요청 중 문제가 발생했습니다: $e', snackPosition: SnackPosition.BOTTOM); 
    }
  }


  // 금액 포맷 유틸리티
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.round())}원';
  }

  // 뷰 전환 버튼 위젯 (기존과 동일)
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

  // 뷰 전환 개별 버튼 위젯 (기존과 동일)
  Widget _buildViewButton(String title, OrderView view) {
    final isSelected = _currentView == view;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            _currentView = view;
          });
        },
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          '내역 관리',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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

  // 검색창 위젯 (기존과 동일)
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
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '내역 검색',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onSubmitted: (value) {
            // TODO: 검색 로직 구현 
          },
        ),
      ),
    );
  }

  // 주문 내역 리스트 View (기존과 동일)
  Widget _buildPurchaseView() {
    if (_purchaseDetails.isEmpty) {
      return Center(child: Text('$_currentUserId 님의 주문 내역이 없습니다.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: _buildOrderList(_purchaseDetails)),
    );
  }

  // 반품 내역 리스트 View (기존과 동일)
  Widget _buildRefundView() {
    if (_refundDetails.isEmpty) {
      return Center(child: Text('$_currentUserId 님의 반품 내역이 없습니다.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: _buildRefundList(_refundDetails)), 
    );
  }

  // 주문 내역 리스트 위젯들을 생성하는 함수 (기존과 동일)
  List<Widget> _buildOrderList(List<OrderDetail> details) {
    Map<String, List<OrderDetail>> groupedOrders = {};
    for (var detail in details) {
      String date = detail.purchase.pdate.split(' ')[0].replaceAll('-', '.');
      if (!groupedOrders.containsKey(date)) { groupedOrders[date] = []; }
      groupedOrders[date]!.add(detail);
    }

    List<Widget> listWidgets = [];
    final sortedDates = groupedOrders.keys.toList()..sort((a, b) => b.compareTo(a));

    for (var date in sortedDates) {
      listWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
          child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );

      for (var orderDetail in groupedOrders[date]!) { 
        listWidgets.add(_buildOrderItemCard(orderDetail)); 
      }
    }
    return listWidgets;
  }

  // 개별 주문 상품 카드 위젯 (⭐️ 탭 로직에 주문 취소 추가)
  Widget _buildOrderItemCard(OrderDetail detail) {
    final Purchase purchase = detail.purchase;
    final String status = _purchaseStatusMap[purchase.pstatus] ?? '상태불명';
    
    // ⭐️ 카드 탭 시 실행할 함수 정의 (주문 취소 로직 추가)
    void handleCardTap() {
      // 1. 수령 완료 상태: 반품 요청 다이얼로그
      if (purchase.pstatus == 4) {
        Get.defaultDialog(
          title: '반품 요청 확인',
          middleText: '해당 주문 상품에 대해 반품 요청을 진행하시겠습니까?',
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('아니요')),
            ElevatedButton(
              onPressed: () {
                Get.back(); 
                _requestRefund(detail); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('예'),
            ),
          ],
        );
      } 
      // 2. 결제 완료 상태: 주문 취소 다이얼로그 (출고 준비 중인 상태(3)에서도 취소 가능할 수 있음)
      else if (purchase.pstatus == 2 || purchase.pstatus == 3) {
        Get.defaultDialog(
          title: '주문 취소 확인',
          middleText: '주문을 취소하고 결제를 환불하시겠습니까?',
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('아니요')),
            ElevatedButton(
              onPressed: () {
                Get.back(); 
                _cancelOrder(detail); // ⭐️ 주문 취소 함수 호출
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('예, 취소합니다'),
            ),
          ],
        );
      }
      // 3. 기타 상태 (취소됨, 요청 중): 알림 표시
      else {
        Get.snackbar(
          '알림', 
          '[$status] 상태이므로 취소/반품 요청이 불가합니다.', 
          snackPosition: SnackPosition.BOTTOM
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // ⭐️ InkWell 추가: 카드 전체를 탭 가능하게 만듭니다.
      child: InkWell(
        onTap: handleCardTap, // 탭 핸들러 연결
        borderRadius: BorderRadius.circular(10), // Container의 borderRadius와 맞춥니다.
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상품 이미지 (아이콘 플레이스홀더로 대체)
              Container( 
                width: 80, height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), 
                  color: Colors.grey.shade200, 
                ),
                child: ClipRRect( 
                  borderRadius: BorderRadius.circular(8),
                  child: const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 40)),
                ),
              ),
              const SizedBox(width: 15),
  
              // 2. 상품 정보 (상품명과 색상/옵션 표시)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.itemName, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 5),
                    Text(
                      detail.itemOptions, 
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600)
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_formatCurrency(purchase.ppayprice)}  ${purchase.pamount}개', 
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600)
                    ),
                  ],
                ),
              ),
  
              // 3. 상태 표시
              _buildStatusDisplay(detail, status), 
            ],
          ),
        ),
      ),
    );
  }

  // ⭐️ 상태만 표시하는 위젯 (기존과 동일)
  Widget _buildStatusDisplay(OrderDetail detail, String status) {
      Color buttonColor = Colors.grey.shade200;
      Color textColor = Colors.black;

      if (status == '결제 완료' || status == '출고 준비') {
          textColor = Colors.blue;
      } else if (status == '수령 완료') {
          textColor = Colors.green.shade700;
      } else if (status == '주문 취소됨') { // ⭐️ 취소된 주문의 색상
          textColor = Colors.red.shade700;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          status, 
          style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
        ),
      );
  }

  // 반품 내역 리스트 위젯들을 생성하는 함수 (기존과 동일)
  List<Widget> _buildRefundList(List<RefundDetail> details) {
    Map<String, List<RefundDetail>> groupedRefunds = {};
    for (var detail in details) {
      String date = detail.refund.rdate.split(' ')[0].replaceAll('-', '.');
      if (!groupedRefunds.containsKey(date)) { groupedRefunds[date] = []; }
      groupedRefunds[date]!.add(detail);
    }

    List<Widget> listWidgets = [];
    final sortedDates = groupedRefunds.keys.toList()..sort((a, b) => b.compareTo(a));

    for (var date in sortedDates) {
      listWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
          child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );

      for (var refundDetail in groupedRefunds[date]!) {
        listWidgets.add(_buildRefundItemCard(refundDetail));
      }
    }
    return listWidgets;
  }

  // 개별 반품 상품 카드 위젯 (기존과 동일)
  Widget _buildRefundItemCard(RefundDetail detail) {
    final Refund refund = detail.refund;
    final String status = _refundStatusMap[refund.rstatus] ?? '상태불명';
    
    Color textColor;
    switch(refund.rstatus) {
      case 1: textColor = Colors.orange.shade700; break;
      case 2: textColor = Colors.blue.shade700; break;
      case 3: textColor = Colors.green.shade700; break;
      default: textColor = Colors.black;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 (임시)
            Container( 
              width: 80, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Center(
                    child: Text('반품', style: TextStyle(color: Colors.grey.shade500))),
              ),
            ),
            const SizedBox(width: 15),

            // 2. 정보 및 사유
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail.itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis), 
                  const SizedBox(height: 5),
                  Text('사유: ${refund.rreason}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  Text('요청일: ${refund.rdate.split(' ')[0]}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),

            // 3. 반품 상태 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                status, 
                style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}