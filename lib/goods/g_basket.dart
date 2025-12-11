import 'package:flutter/material.dart';

class GBasket extends StatefulWidget {
  const GBasket({super.key});

  @override
  State<GBasket> createState() => _GBasketState();
}

class _GBasketState extends State<GBasket> {
  // 장바구니 항목 개별 위젯 빌더
  Widget _buildBasketItem({required String imagePath}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        // Card의 elevation을 주어 약간의 입체감과 그림자 효과 추가
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
                  const Icon(Icons.check_box, color: Colors.black), // 체크박스 아이콘
                  const SizedBox(width: 10),
                  
                  // 상품 이미지 (왼쪽)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePath, // [여기에 이미지 경로: images/shoe.png]
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),

                  // 상품 텍스트 정보 (중앙)
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '나이키 매직포스 파워레인저 화이트',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Nike Magic Force Power Rangers White',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // 삭제 버튼 (오른쪽)
                  const Icon(Icons.close, color: Colors.grey, size: 20),
                ],
              ),

              const Divider(height: 30, thickness: 1, color: Colors.black12),

              // 2. 결제 금액 및 수수료 정보
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 결제 금액
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('결제 금액', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  // 가격
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '100,000원',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  // 옵션 변경 버튼 (어두운 회색)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('옵션변경'),
                  ),
                  const SizedBox(width: 10),
                  // 바로 주문 버튼 (빨간색)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935), // 이미지와 유사한 빨간색
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
            onPressed: () {
              //
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              //
            },
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      
      // 2. 스크롤 가능한 장바구니 목록
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBasketItem(imagePath: 'images/shoe1.png'), // [여기에 이미지 경로: images/shoe1.png]
            _buildBasketItem(imagePath: 'images/shoe2.png'), // [여기에 이미지 경로: images/shoe2.png]
            // ... 필요한 만큼 아이템 추가
            const SizedBox(height: 100), // 하단 Floating Bar 공간 확보
          ],
        ),
      ),
      
      // 3. 하단 고정된 결제 버튼 영역 (BottomNavigationBar 대신 FloatingActionButton을 사용하여 하단 고정)
      bottomSheet: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFE53935), // 빨간색 배경
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '209,200원 · 총 2개 상품 구매하기',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}