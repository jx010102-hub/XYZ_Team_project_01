// lib/goods/g_main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/insert/goods_detail_page.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';
import 'dart:math';
import 'dart:typed_data';

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

  // 대표 상품 리스트
  List<Goods> recommendedGoods = []; // 오늘의 추천 (슬라이더)
  List<Goods> popularGoods = [];     // 인기 상품 (가로 스크롤)
  List<Goods> recentGoods = [];      // 최근 본 상품 (가로 스크롤)

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoodsData();

    _pageController.addListener(() {
      final page = _pageController.page;
      if (page == null) return;

      int next = page.round();
      if (_currentPage != next && mounted) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  // 상품 데이터 로드
  Future<void> _loadGoodsData() async {
    try {
      final goodsDB = GoodsDatabase();
      final all = await goodsDB.queryGoods();

      print("====================================");
      print("DB에서 불러온 전체 상품 수 (옵션 포함): ${all.length}");

      if (all.isNotEmpty) {
        // 1. GNAME별로 그룹화해서 첫 번째 항목만 대표로 사용
        final Map<String, Goods> uniqueGoodsMap = {};
        for (var goods in all) {
          if (!uniqueGoodsMap.containsKey(goods.gname)) {
            uniqueGoodsMap[goods.gname] = goods;
          }
        }

        List<Goods> representativeGoods = uniqueGoodsMap.values.toList();
        final int totalCount = representativeGoods.length;

        if (totalCount == 0) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
          print("Error: 대표 상품 그룹이 없습니다.");
          print("====================================");
          return;
        }

        // 2. 섹션별 랜덤 추출 (겹침 허용)
        representativeGoods.shuffle(Random());
        final rec = representativeGoods.take(min(4, totalCount)).toList();

        representativeGoods.shuffle(Random());
        final pop = representativeGoods.take(min(5, totalCount)).toList();

        representativeGoods.shuffle(Random());
        final recent = representativeGoods.take(min(5, totalCount)).toList();

        if (!mounted) return;
        setState(() {
          recommendedGoods = rec;
          popularGoods = pop;
          recentGoods = recent;
          isLoading = false;
        });

        print("✅ 대표 상품 그룹 로드 성공. 총 그룹 수: $totalCount");
        print("✅ 섹션별 중복 추출 완료.");
        print("====================================");
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        print("Error: 상품 데이터가 DB에 없어 로딩을 해제합니다.");
        print("====================================");
      }
    } catch (e, st) {
      // ❗ 여기서 에러만 찍고 앱이 죽지 않게 막음
      print("GMain _loadGoodsData 에러: $e");
      print(st);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'images/xyz_logo.png',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 추천 타이틀
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 15),
              child: Text(
                "오늘의 추천 🔥",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 슬라이드 카드 + 화살표 버튼
            SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: recommendedGoods.length,
                    itemBuilder: (context, index) {
                      return _buildShoeCard(recommendedGoods[index]);
                    },
                  ),
                  Positioned(
                    right: 15,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
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

            // 인디케이터
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 0, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  recommendedGoods.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
            ),

            // 인기 상품 타이틀
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 15),
              child: Text(
                "인기 상품 🏆",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 인기 상품 가로 스크롤
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: popularGoods.length,
                itemBuilder: (context, index) {
                  return _buildPopularItemCard(popularGoods[index]);
                },
              ),
            ),

            // 최근 본 상품 타이틀
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 0, 15),
              child: Text(
                "최근 본 상품 📍",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 최근 본 상품 가로 스크롤
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recentGoods.length,
                  itemBuilder: (context, index) {
                    return _buildPopularItemCard(recentGoods[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 메인 슬라이더 카드
  Widget _buildShoeCard(Goods goods) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => GoodsDetailPage(goods: goods, userid: widget.userid),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // 🔴 withValues → ✅ withOpacity 로 변경
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
            // 이미지
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
            // 텍스트 정보
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goods.gcategory,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    goods.gname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
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

  // 인기/최근 상품 카드
  Widget _buildPopularItemCard(Goods goods) {
    const double cardWidth = 150;
    const double imageBoxHeight = 120;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => GoodsDetailPage(goods: goods, userid: widget.userid),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 박스
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
            Text(
              goods.gengname,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              goods.gname,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
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

  // 인디케이터
  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // 다음 페이지로 이동
  void _nextPage() {
    if (recommendedGoods.isEmpty) return;

    if (_currentPage < recommendedGoods.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }
}
