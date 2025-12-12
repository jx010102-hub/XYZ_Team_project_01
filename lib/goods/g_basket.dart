import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 금액 포맷팅을 위해 intl 패키지 필요
import 'package:get/get.dart';
import 'package:xyz_project_01/controller/store_controller.dart';

// ⭐️ 1. 장바구니 항목의 데이터 구조 정의
class BasketItem {
  final int id;
  final String name;
  final String engName;
  final String imagePath;
  final double price; // 상품 개별 가격
  int quantity;       // 수량 (수정 가능)
  bool isChecked;     // 선택 상태

  BasketItem({
    required this.id,
    required this.name,
    required this.engName,
    required this.imagePath,
    required this.price,
    this.quantity = 1,
    this.isChecked = true,
  });
}

class GBasket extends StatefulWidget {
  final String userid;
  const GBasket({super.key, required this.userid});

  @override
  State<GBasket> createState() => _GBasketState();
}

class _GBasketState extends State<GBasket> {
  
  final StoreController storeController = Get.find<StoreController>();

  // ⭐️ 2. 장바구니 목록 상태 변수
  List<BasketItem> _items = [];
  
  // ⭐️ 3. 총 금액 및 수량 상태 변수
  double _totalPrice = 0;
  int _totalQuantity = 0;

  @override
  void initState() {
    super.initState();
    // 초기 데이터 설정
    _items = [
      BasketItem(
        id: 1, 
        name: '나이키 매직포스 파워레인저 화이트',
        engName: 'Nike Magic Force Power Rangers White',
        imagePath: 'images/shoe1.png', 
        price: 100000, // 100,000원
        quantity: 1,
        isChecked: true,
      ),
      BasketItem(
        id: 2, 
        name: '아디다스 퓨처러너 블랙',
        engName: 'Adidas Future Runner Black',
        imagePath: 'images/shoe2.png', 
        price: 109200, // 109,200원
        quantity: 2, // 수량 테스트를 위해 2로 설정
        isChecked: true,
      ),
    ];
    _calculateTotals(); // 초기 총액 계산
  }
  
  // ⭐️ 4. 총액 및 수량 계산 로직
  void _calculateTotals() {
    double newTotal = 0;
    int newQuantity = 0;
    
    for (var item in _items) {
      if (item.isChecked) {
        newTotal += item.price * item.quantity;
        newQuantity += item.quantity;
      }
    }

    // 상태 업데이트
    setState(() {
      _totalPrice = newTotal;
      _totalQuantity = newQuantity;
    });
  }

  // ⭐️ 5. 수량 업데이트 로직
  void _updateQuantity(BasketItem item, int change) {
    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity >= 1) {
        item.quantity = newQuantity;
        _calculateTotals();
      }
    });
  }


  // ⭐️ 6. 금액 포맷 유틸리티
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.round())}원';
  }

  // ⭐️ 7. 버튼 클릭 시 호출되는 다이얼로그 함수
  void _showNotImplementedDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action'),
          content: const Text('현재 해당 기능은 구현 중입니다. 🚧'),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 장바구니 항목 개별 위젯 빌더 (동적 데이터 사용)
  Widget _buildBasketItem(BasketItem item) { 
    // 현재 항목의 총 금액 계산
    double itemTotalPrice = item.price * item.quantity; 

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // 1. 체크박스, 상품 정보, 삭제 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐️ 체크박스: 상태에 따라 토글되며 총액 계산 함수 호출
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        item.isChecked = !item.isChecked;
                      });
                      _calculateTotals();
                    },
                    child: Icon(
                      item.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                      color: item.isChecked ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // 상품 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.imagePath, 
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),

                  // 상품 텍스트 정보 (중앙)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name, 
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.engName, 
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // ⭐️ 삭제 버튼: 다이얼로그 호출
                  GestureDetector(
                    onTap: () => _showNotImplementedDialog(context, '항목 삭제'),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              
              const Divider(height: 30, thickness: 1, color: Colors.black12),

              // 2. 수량 조절, 결제 금액 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ⭐️⭐️⭐️ 수량 조절 위젯 추가 ⭐️⭐️⭐️
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () => _updateQuantity(item, -1),
                          // 수량이 1일 경우 버튼 비활성화
                          color: item.quantity > 1 ? Colors.black : Colors.grey, 
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => _updateQuantity(item, 1),
                        ),
                      ],
                    ),
                  ),
                  
                  // 결제 금액
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('총 상품 금액', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        _formatCurrency(itemTotalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // 3. 옵션 변경 및 바로 주문 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ⭐️ 옵션 변경 버튼: 다이얼로그 호출
                  ElevatedButton(
                    onPressed: () => _showNotImplementedDialog(context, '옵션 변경'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('옵션변경'),
                  ),
                  const SizedBox(width: 10),
                  // ⭐️ 바로 주문 버튼: 다이얼로그 호출
                  ElevatedButton(
                    onPressed: () => _showNotImplementedDialog(context, '바로 주문'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('바로주문'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png', // 이미지 경로
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      
      // 2. 스크롤 가능한 장바구니 목록
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ⭐️ items 리스트의 모든 항목을 동적으로 빌드
            ..._items.map((item) => _buildBasketItem(item)).toList(), 
            
            const SizedBox(height: 100), // 하단 Floating Bar 공간 확보
          ],
        ),
      ),
      
      // 3. 하단 고정된 결제 버튼 영역
      // 3. 하단 고정된 결제 버튼 영역
      bottomSheet: Obx(() {
        final store = storeController.selectedStore.value;

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // 실제 색은 내부에서 나뉨
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 1) 구매하기 영역 (빨간색)
              GestureDetector(
                onTap: () => _showNotImplementedDialog(
                    context,
                    '총 ${_totalQuantity}개 상품 구매하기'
                ),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: const Color(0xFFE53935), // 빨간 영역
                  alignment: Alignment.center,
                  child: Text(
                    '${_formatCurrency(_totalPrice)} · 총 ${_totalQuantity}개 상품 구매하기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 🟦 선택 매장 정보 영역(있을 때만 표시)
              if (store != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,      // 매장정보 박스 배경 = 흰색
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.store, color: Colors.black87, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['name'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${store['district']} · ${store['address']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 변경 버튼 눌렀을 때 동작
                          _showNotImplementedDialog(context, "매장 변경하기");
                        },
                        child: const Text(
                          "변경",
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}