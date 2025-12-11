// lib/g_main.dart 파일 전체 내용

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/insert/goods_detail_page.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';
import 'dart:math';
import 'dart:typed_data'; // Uint8List 사용을 위해 추가

class GMain extends StatefulWidget {
  final String userid;
  const GMain({super.key, required this.userid});

  @override
  State<GMain> createState() => _GMainState();
}

class _GMainState extends State<GMain> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );
  int _currentPage = 0;
  
  // DB에서 불러올 실제 상품 리스트 (대표 상품만 포함)
  List<Goods> recommendedGoods = []; // 오늘의 추천 (슬라이더)
  List<Goods> popularGoods = [];     // 인기 상품 (가로 스크롤)
  List<Goods> recentGoods = [];      // 최근 본 상품 (가로 스크롤)
  
  // 로딩 상태 변수
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoodsData(); 
    
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  // ⭐️⭐️⭐️ _loadGoodsData 함수: 상품 그룹별 추출 및 섹션별 중복 추출 허용 ⭐️⭐️⭐️
  Future<void> _loadGoodsData() async {
    final goodsDB = GoodsDatabase();
    final all = await goodsDB.queryGoods();
    
    print("====================================");
    print("DB에서 불러온 전체 상품 수 (옵션 포함): ${all.length}"); 
    
    if (all.isNotEmpty) {
      // 1. GNAME별로 그룹화하고, 각 그룹의 첫 번째 항목만 추출 (대표 상품)
      final Map<String, Goods> uniqueGoodsMap = {};
      
      for (var goods in all) {
        if (!uniqueGoodsMap.containsKey(goods.gname)) {
          uniqueGoodsMap[goods.gname] = goods;
        }
      }
      
      // 2. 대표 상품 리스트 생성
      List<Goods> representativeGoods = uniqueGoodsMap.values.toList();
      final int totalCount = representativeGoods.length;
      
      // 상품 그룹이 없다면 로딩 해제 후 종료
      if (totalCount == 0) {
          setState(() {
            isLoading = false;
          });
          print("Error: 대표 상품 그룹이 없습니다.");
          print("====================================");
          return;
      }
      
      // 3. 섹션별로 독립적으로 무작위 추출 및 할당 (겹침 허용)
      
      // '오늘의 추천' (슬라이더, 최대 4개)
      representativeGoods.shuffle(Random()); 
      recommendedGoods = representativeGoods.take(min(4, totalCount)).toList();

      // '인기 상품' (가로 스크롤, 최대 5개)
      representativeGoods.shuffle(Random()); 
      popularGoods = representativeGoods.take(min(5, totalCount)).toList();

      // '최근 본 상품' (가로 스크롤, 최대 5개)
      representativeGoods.shuffle(Random()); 
      recentGoods = representativeGoods.take(min(5, totalCount)).toList();
      
      
      print("✅ 대표 상품 그룹 로드 성공. 총 그룹 수: $totalCount");
      print("✅ 섹션별 중복 추출 완료.");
      print("====================================");
      
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error: 상품 데이터가 DB에 없어 로딩을 해제합니다.");
      print("====================================");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 화면
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              //
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),

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
                    itemCount: recommendedGoods.length, 
                    itemBuilder: (context, index) {
                      return _buildShoeCard(
                        recommendedGoods[index], 
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
                  recommendedGoods.length, 
                  (index) => _buildIndicator(
                    index == _currentPage,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
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
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                itemCount: popularGoods.length, 
                itemBuilder: (context, index) {
                  return _buildPopularItemCard(
                    popularGoods[index], 
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
            // 6. 섹션 타이틀 ('최근 본 상품')
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

            // 7. 최근 본 상품 가로 스크롤 섹션
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                itemCount: recentGoods.length, 
                itemBuilder: (context, index) {
                  return _buildPopularItemCard(
                    recentGoods[index], 
                  );
                },
              ),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  // ⭐️ _buildShoeCard 함수: 가격 고정 및 이미지 처리 ⭐️
  Widget _buildShoeCard(Goods goods) {
    return GestureDetector(
      onTap: () {
        Get.to(GoodsDetailPage(goods: goods, userid: widget.userid,));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
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
            // 신발 이미지 영역 (DB에서 불러온 이미지 사용)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: goods.mainimage != null && goods.mainimage is Uint8List
                    ? Image.memory(
                        goods.mainimage!, 
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Center( 
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // 텍스트 정보 영역 (Goods 객체의 실제 정보 사용)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    goods.gcategory, // 카테고리 사용
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    goods.gname, // 제품명 사용
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // 금액 표시: "150,000원"으로 고정
                  const Text(
                    "150,000원", 
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

  // ⭐️ _buildPopularItemCard 함수: 가격 고정 및 이미지 처리 ⭐️
  Widget _buildPopularItemCard(Goods goods) {
    const double cardWidth = 150;
    const double imageBoxHeight = 120;

    return GestureDetector(
      onTap: () {
        Get.to(GoodsDetailPage(goods: goods, userid: widget.userid,));
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 15), // 카드 간 간격
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 박스 (DB에서 불러온 이미지 사용)
            Container(
              height: imageBoxHeight,
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: goods.mainimage != null && goods.mainimage is Uint8List
                    ? Image.memory(
                        goods.mainimage!, 
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // 2. 텍스트 정보
            Text(
              goods.gengname, // 영문명(브랜드 역할로 가정) 사용
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              goods.gname, // 제품명 사용
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            // 금액 표시: "150,000원"으로 고정
            const Text(
              "150,000원", 
              style: TextStyle(
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

  // 다음 페이지로 이동하는 함수
  void _nextPage() {
    if (_currentPage < recommendedGoods.length - 1) {
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
}