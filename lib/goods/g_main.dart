import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/insert/goods_detail_page.dart';
import 'package:xyz_project_01/model/goods.dart';

class GMain extends StatefulWidget {
  const GMain({super.key});

  @override
  State<GMain> createState() => _GMainState();
}

class _GMainState extends State<GMain> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );
  int _currentPage = 0;
  final List recommendedShoes = [
    'images/shoe1.png',
    'images/shoe2.png',
    'images/shoe3.png',
    'images/shoe4.png',
  ];

  @override
  void initState() {
    super.initState();
    // 페이지가 변경될 때마다 _currentPage를 업데이트하도록 리스너 추가
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

      // _MainScreenState 클래스 내부의 build 메서드 리턴 부분 (Scaffold body)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. 섹션 타이틀 ('오늘의 추천')
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Text(
                "오늘의 추천 🔥",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 2. 슬라이드 및 버튼 영역 (Stack을 사용하여 겹치기)
            SizedBox(
              height: 320, // 카드의 높이 지정
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // A. 실제 슬라이더 (PageView)
                  PageView.builder(
                    controller: _pageController,
                    itemCount: recommendedShoes.length,
                    itemBuilder: (context, index) {
                      return _buildShoeCard(
                        recommendedShoes[index],
                      );
                    },
                  ),

                  // B. 다음 페이지 버튼 (>)
                  Positioned(
                    right: 15,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                      ),
                      iconSize: 30,
                      color: Colors.black,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white70,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 3. 페이지 인디케이터 (슬라이더 바)
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
              ), // 왼쪽으로 정렬
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  recommendedShoes.length,
                  (index) => _buildIndicator(
                    index == _currentPage,
                  ),
                ),
              ),
            ),

            // _GMainState 클래스 내부의 build 메서드 > body: Column의 children[] 목록에 추가
            const SizedBox(height: 30), // 슬라이더와 인기상품 사이 간격
            // 4. 섹션 타이틀 ('인기 상품')
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Text(
                "인기 상품 🏆",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 5. 인기 상품 가로 스크롤 섹션
            SizedBox(
              height:
                  220, // 전체 가로 스크롤 섹션의 높이 지정 (카드 높이 + 텍스트 높이)
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal, // 핵심: 가로 스크롤 설정
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ), // 좌우 패딩
                itemCount: 5, // 임시로 5개 아이템을 보여주도록 설정
                itemBuilder: (context, index) {
                  // TODO: 실제 데이터 리스트를 사용하도록 변경해야 합니다.
                  // 현재는 임시 데이터로 "Skechers Go Run" 정보를 사용합니다.
                  return _buildPopularItemCard(
                    'images/popular_shoe_${index + 1}.png', // 임시 이미지 경로
                    '스케쳐스',
                    '고 런 엘리베이트',
                    '119,000원',
                  );
                },
              ),
            ),

            // _GMainState 클래스 내부의 build 메서드 > body: Column의 children[] 목록에 추가
            const SizedBox(height: 30), // 슬라이더와 인기상품 사이 간격
            // 5. 섹션 타이틀 ('최근 본 상품')
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Text(
                "최근 본 상품 📍",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 5. 인기 상품 가로 스크롤 섹션
            SizedBox(
              height:
                  220, // 전체 가로 스크롤 섹션의 높이 지정 (카드 높이 + 텍스트 높이)
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal, // 핵심: 가로 스크롤 설정
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ), // 좌우 패딩
                itemCount: 5, // 임시로 5개 아이템을 보여주도록 설정
                itemBuilder: (context, index) {
                  // TODO: 실제 데이터 리스트를 사용하도록 변경해야 합니다.
                  // 현재는 임시 데이터로 "Skechers Go Run" 정보를 사용합니다.
                  return _buildPopularItemCard(
                    'images/popular_shoe_${index + 1}.png', // 임시 이미지 경로
                    '스케쳐스',
                    '고 런 엘리베이트',
                    '119,000원',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  } //

  // _GMainState 클래스 내부
  Widget _buildShoeCard(String imagePath) {
    // 상품 상세 페이지로 전달할 임시 Goods 객체 생성 (동일)
    final Goods dummyGoods = Goods(
      gsumamount: 50,
      gname: "오늘의 추천 특별 한정판 신발",
      gengname: "Today's Recommended Exclusive Shoe",
      gsize: "270",
      gcolor: "Black",
      gcategory: "스니커즈",
    );

    return GestureDetector(
      onTap: () {
        Get.to(GoodsDetailPage(goods: dummyGoods));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
        ), // 카드 간 간격
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 신발 이미지 영역
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  imagePath, // 전달받은 이미지 경로 사용
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // 이미지 로딩 오류 발생 시 간단한 대체 화면
                  errorBuilder:
                      (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        );
                      },
                ),
              ),
            ),

            // 임시 텍스트 정보 영역 (이미지 경로만 받으므로 임시로 넣었습니다)
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "BEST BRAND",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Best Recommended Shoe",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "159,000원",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _GMainState 클래스 내부
  Widget _buildPopularItemCard(
    String imagePath,
    String brand,
    String name,
    String price,
  ) {
    // 요청하신 '위쪽 슬라이드 사진 보다 반 정도의 크기'를 반영하여 높이를 120으로 설정
    const double cardWidth = 150; // 카드의 너비
    const double imageBoxHeight = 120; // 이미지 영역의 높이

    // 상품 상세 페이지로 전달할 임시 Goods 객체 생성 (동일)
    final Goods dummyGoods = Goods(
      gsumamount: 30,
      gname: name,
      gengname: brand,
      gsize: "250",
      gcolor: "Navy",
      gcategory: "러닝화",
    );

    return GestureDetector(
      onTap: () {
        Get.to(GoodsDetailPage(goods: dummyGoods));
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 15), // 카드 간 간격
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 박스 (슬라이드 박스 높이 320의 반 정도인 120으로 설정)
            Container(
              height: imageBoxHeight,
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.grey[200], // 배경색을 살짝 넣어줍니다.
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.grey,
                          ),
                        );
                      },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 2. 텍스트 정보
            Text(
              brand, // '스케쳐스'
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name, // '고 런 엘리베이트'
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              price, // '119,000원'
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _GMainState 클래스 내부
  // 페이지 인디케이터 동그라미 위젯
  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0, // 활성화된 동그라미는 길쭉하게
      decoration: BoxDecoration(
        color: isActive
            ? Colors.black
            : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  //-------function

  // 다음 페이지로 이동하는 함수
  void _nextPage() {
    if (_currentPage < recommendedShoes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      // 마지막 페이지라면 첫 페이지로 순환
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }
} //
