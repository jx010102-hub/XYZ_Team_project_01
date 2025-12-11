import 'package:flutter/material.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // 1. 섹션 타이틀 ('오늘의 추천')
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                (index) =>
                    _buildIndicator(index == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  } //

  // _GMainState 클래스 내부
  Widget _buildShoeCard(String imagePath) {
    return Container(
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
                errorBuilder: (context, error, stackTrace) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
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

  //-------

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
