import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/model/purchase.dart'; // Purchase 모델 임포트
import 'package:xyz_project_01/vm/database/purchase_database.dart'; // PurchaseDatabase 임포트
import 'package:intl/intl.dart'; // 가격 포맷팅을 위해 추가

// ⭐️ DB에서 가져온 Purchase 객체와 함께 UI 표시를 위한 정보를 담는 헬퍼 클래스
class OrderDetail {
  final Purchase purchase;
  // ⚠️ 상품 정보는 Goods 테이블과의 조인이나 별도 로직으로 가져와야 하나, 현재는 더미로 처리
  final String itemName;
  final String itemImageUrl;

  OrderDetail({
    required this.purchase,
    required this.itemName,
    required this.itemImageUrl,
  });
}

class GoodsProfillBuyPage extends StatefulWidget {
  // ⭐️ userid를 받기 위한 final 변수 추가
  final String userId; 
  
  // ⭐️ 생성자 수정: userId를 필수 인자로 받도록 변경
  const GoodsProfillBuyPage({super.key, required this.userId}); 

  @override
  State<GoodsProfillBuyPage> createState() =>
      _GoodsProfillBuyPageState();
}

class _GoodsProfillBuyPageState
    extends State<GoodsProfillBuyPage> {
  late TextEditingController _searchController;
  
  // ⭐️ DB에서 불러온 실제 주문 내역 리스트 (Purchase 객체 기반)
  List<OrderDetail> _orderDetails = [];
  bool _isLoading = true;

  // ⭐️ 현재 로그인된 사용자 ID를 위젯에서 가져오도록 변경
  late String _currentUserId; 

  // ⭐️ 주문 상태를 텍스트로 변환하는 맵
  final Map<int, String> _statusMap = {
    1: '주문 요청', 
    2: '결제 완료', 
    3: '출고 준비', 
    4: '수령 완료'
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // ⭐️ 위젯에서 전달받은 userId를 사용하도록 설정
    _currentUserId = widget.userId; 
    
    _loadUserPurchases(); // DB에서 구매 내역 로드 시작
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ⭐️⭐️⭐️ 사용자 구매 내역을 DB에서 로드하는 함수 ⭐️⭐️⭐️
  Future<void> _loadUserPurchases() async {
    setState(() {
      _isLoading = true;
    });

    final PurchaseDatabase db = PurchaseDatabase();
    
    // 1. 현재 사용자 ID로 Purchase 테이블 조회
    List<Purchase> purchases = await db.queryPurchaseByUserId(_currentUserId);
    
    // 2. 임시 상품 정보로 OrderDetail 구성
    List<OrderDetail> details = purchases.map((p) {
      // ⚠️ 여기에 실제 상품명과 이미지 URL을 Goods 테이블에서 가져오는 로직이 필요합니다.
      // 현재는 Purchase 객체만 있으므로 더미 정보를 사용합니다.
      return OrderDetail(
        purchase: p,
        // TODO: 실제 상품명으로 대체
        itemName: '상품 옵션 (PSEQ: ${p.pseq})', 
        // TODO: 실제 이미지 URL로 대체
        itemImageUrl: 'images/shoe_brown.png', 
      );
    }).toList();

    setState(() {
      _orderDetails = details;
      _isLoading = false;
    });
  }


  // ⭐️ 금액 포맷 유틸리티
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.round())}원';
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
          '주문내역',
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

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
                : _orderDetails.isEmpty
                    ? Center(child: Text('$_currentUserId 님의 주문 내역이 없습니다.')) // 주문 내역 없을 때
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        // ⭐️ DB 로드된 데이터를 기반으로 리스트 생성
                        child: Column(children: _buildOrderList(_orderDetails)), 
                      ),
          ),
        ],
      ),
    );
  }

  // 검색창 위젯
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
            hintText: '주문한 상품을 검색하세요.',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onSubmitted: (value) {
            // TODO: 검색 로직 구현 (_orderDetails 필터링)
            print('검색 실행: $value');
          },
        ),
      ),
    );
  }

  // 주문 내역 리스트 위젯들을 생성하는 함수
  List<Widget> _buildOrderList(List<OrderDetail> details) {
    // 주문을 날짜별로 그룹화합니다.
    Map<String, List<OrderDetail>> groupedOrders = {};
    for (var detail in details) {
      // 주문일자(pdate)를 YYYY.MM.DD 형식으로 포맷
      String date = detail.purchase.pdate.split(' ')[0].replaceAll('-', '.');
      
      if (!groupedOrders.containsKey(date)) {
        groupedOrders[date] = [];
      }
      groupedOrders[date]!.add(detail);
    }

    List<Widget> listWidgets = [];

    // 날짜를 최신순으로 정렬 (Map의 Keys를 List로 변환 후 정렬)
    final sortedDates = groupedOrders.keys.toList()..sort((a, b) => b.compareTo(a));

    for (var date in sortedDates) {
      final orders = groupedOrders[date]!;
      
      // 1. 날짜 헤더
      listWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 5, bottom: 8),
          child: Text(
            date,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // 2. 주문 상품 카드 리스트
      for (var orderDetail in orders) {
        listWidgets.add(_buildOrderItemCard(orderDetail));
      }
    }

    return listWidgets;
  }

  // 개별 주문 상품 카드 위젯
  Widget _buildOrderItemCard(OrderDetail detail) {
    final Purchase purchase = detail.purchase;
    final String status = _statusMap[purchase.pstatus] ?? '상태불명';
    
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
            // 1. 상품 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  detail.itemImageUrl, // 더미 이미지 사용
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text('이미지', style: TextStyle(color: Colors.grey.shade500)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),

            // 2. 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.itemName, // 더미 상품명 사용
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_formatCurrency(purchase.ppayprice)}  ${purchase.pamount}개', 
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // 3. 상태 버튼
            _buildStatusButton(status),
          ],
        ),
      ),
    );
  }

  // 상태에 따른 버튼 위젯
  Widget _buildStatusButton(String status) {
    Color buttonColor;
    Color textColor;

    switch (status) {
      case '결제 완료':
        buttonColor = Colors.grey.shade300;
        textColor = Colors.blue;
        break;
      case '수령 완료':
        buttonColor = Colors.grey.shade300;
        textColor = Colors.black;
        break;
      default:
        buttonColor = Colors.grey.shade200;
        textColor = Colors.black;
    }

    return ElevatedButton(
      onPressed: () {
        // TODO: 버튼 클릭 시 상세 주문 정보 확인/반품 신청 등의 로직 구현
        print('${status} 버튼 클릭됨');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(status, style: const TextStyle(fontSize: 14)),
    );
  }
}