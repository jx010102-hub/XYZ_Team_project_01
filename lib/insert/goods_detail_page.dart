import 'package:flutter/material.dart';
import 'package:xyz_project_01/model/goods.dart';

class GoodsDetailPage extends StatefulWidget {
  final Goods goods;

  const GoodsDetailPage({super.key, required this.goods});

  @override
  State<GoodsDetailPage> createState() =>
      _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  int _currentImageIndex = 0;

  final List<String> shoeImages = [
    'images/detail_shoe_1.png',
    'images/detail_shoe_2.png',
    'images/detail_shoe_3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImageSection(), // 3. 이미지/슬라이더 섹션
            _buildPriceAndNameSection(), // 4. 가격 및 이름 섹션
            // TODO: 여기에 다른 상세 정보 섹션 추가 (옵션, 리뷰 등)
            const SizedBox(height: 100), // 바닥 여백 확보
          ],
        ),
      ),
      // 5. 하단 고정 구매 버튼 바
      bottomNavigationBar: _buildBottomPurchaseBar(context),
    );
  }

  // _GoodsDetailPageState 클래스 내부
  Widget _buildProductImageSection() {
    return SizedBox(
      height: 400, // 이미지 영역 높이
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 실제 이미지 슬라이더 (PageView)
          PageView.builder(
            itemCount: shoeImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex =
                    index; // 페이지 변경 시 인덱스 업데이트
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                shoeImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
                // 이미지가 로드되지 않을 경우 대비
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              );
            },
          ),

          // 2. 좋아요/공유 버튼 (디자인 이미지 참조)
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  // '좋아요' 버튼
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.thumb_up_alt_outlined,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  // '제품상세 >' 버튼
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    '제품상세 >',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 3. 페이지 인디케이터
          Positioned(
            bottom: 70,
            child: Row(
              children: List.generate(
                shoeImages.length,
                (index) => _buildIndicator(
                  index == _currentImageIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _GoodsDetailPageState 클래스 내부
  Widget _buildPriceAndNameSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그 (주간전체 1위, Top 100. 스니커즈)
          Row(
            children: [
              _buildTag('주간전체 1위'),
              const SizedBox(width: 8),
              _buildTag(
                'Top 100. ${widget.goods.gcategory}',
              ), // Goods 모델의 카테고리 사용
            ],
          ),
          const SizedBox(height: 15),

          // 가격 (Goods 모델에 가격 필드가 없으므로 임시 값 사용)
          const Text(
            "100,000원",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // 제품명 (한글)
          Text(
            widget.goods.gname,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),

          // 제품명 (영문)
          Text(
            widget.goods.gengname,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),

          // 별점 및 리뷰 수 (디자인 이미지 참조)
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 5),
              const Text(
                '4.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' (리뷰 2,000)',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 태그 위젯 (재사용)
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 인디케이터 위젯 (재사용)
  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }

  // _GoodsDetailPageState 클래스 내부
  Widget _buildBottomPurchaseBar(BuildContext context) {
    return Container(
      height: 80, // 하단 바 높이
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          // 1. 좋아요 버튼 (좌측)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 15),

          // 2. 구매하기 버튼 (우측)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: 구매 로직 또는 옵션 선택 팝업 구현
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '구매하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
