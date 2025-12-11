import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Get.back() 사용을 위해 추가

// ⭐️ 더미 데이터 모델 (실제 DB 모델로 대체 필요)
class OrderItem {
  final String date;
  final String name;
  final String price;
  final String quantity;
  final String imageUrl;
  final String status;

  OrderItem({
    required this.date,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.status,
  });
}

class GoodsProfillBuyPage extends StatefulWidget {
  const GoodsProfillBuyPage({super.key});

  @override
  State<GoodsProfillBuyPage> createState() =>
      _GoodsProfillBuyPageState();
}

class _GoodsProfillBuyPageState
    extends State<GoodsProfillBuyPage> {
  late TextEditingController _searchController;

  // ⭐️ [더미 데이터] 이미지에 맞춰 데이터 리스트 구성
  final List<OrderItem> _orders = [
    OrderItem(
      date: '2025.12.11',
      name: '나이키 매직포스 파워레인저 화이트',
      price: '100,000원',
      quantity: '1개',
      imageUrl:
          'images/shoe_brown.png', // 실제 에셋 경로로 변경해야 합니다.
      status: '주문접수',
    ),
    OrderItem(
      date: '2025.10.11',
      name: '나이키 파워레인저',
      price: '100,000원',
      quantity: '1개',
      imageUrl:
          'images/shoe_brown.png', // 실제 에셋 경로로 변경해야 합니다.
      status: '반품완료',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back(); // GetX를 사용하여 이전 화면으로 돌아가기
          },
        ),
        // 2. 타이틀
        title: const Text(
          '주문내역',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // AppBar 아래 그림자 제거
      ),

      body: Column(
        children: [
          // 3. 검색창 섹션
          _buildSearchBar(),

          // 4. 주문 내역 목록 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(children: _buildOrderList()),
            ),
          ),
        ],
      ),

      // 5. 하단 탭바는 GoodsProfill에서 이미 포함되어 있다고 가정하고 제외합니다.
    );
  }

  // ⭐️ 검색창 위젯
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
            border: InputBorder.none, // 기본 border 제거
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
          onSubmitted: (value) {
            // TODO: 검색 로직 구현
            print('검색 실행: $value');
          },
        ),
      ),
    );
  }

  // ⭐️ 주문 내역 리스트 위젯들을 생성하는 함수
  List<Widget> _buildOrderList() {
    // 주문을 날짜별로 그룹화합니다.
    Map<String, List<OrderItem>> groupedOrders = {};
    for (var order in _orders) {
      if (!groupedOrders.containsKey(order.date)) {
        groupedOrders[order.date] = [];
      }
      groupedOrders[order.date]!.add(order);
    }

    List<Widget> listWidgets = [];

    groupedOrders.forEach((date, orders) {
      // 1. 날짜 헤더
      listWidgets.add(
        Padding(
          padding: const EdgeInsets.only(
            top: 15.0,
            left: 5,
            bottom: 8,
          ),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // 2. 주문 상품 카드 리스트
      for (var order in orders) {
        listWidgets.add(_buildOrderItemCard(order));
      }
    });

    return listWidgets;
  }

  // ⭐️ 개별 주문 상품 카드 위젯
  Widget _buildOrderItemCard(OrderItem order) {
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
                  order.imageUrl,
                  fit: BoxFit.cover,
                  // 에셋 로드 실패 시 대체 UI
                  errorBuilder:
                      (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            '이미지',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        );
                      },
                ),
              ),
            ),
            const SizedBox(width: 15),

            // 2. 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    order.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${order.price}  ${order.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 3. 상태 버튼
            _buildStatusButton(order.status),
          ],
        ),
      ),
    );
  }

  // ⭐️ 상태에 따른 버튼 위젯
  Widget _buildStatusButton(String status) {
    Color buttonColor;
    Color textColor;

    // 상태에 따라 색상과 동작을 다르게 설정할 수 있습니다.
    switch (status) {
      case '주문접수':
        buttonColor = Colors.grey.shade300;
        textColor = Colors.blue;
        break;
      case '반품완료':
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
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        status,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
