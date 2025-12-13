// lib/goods/g_tabbar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/controller/store_controller.dart';
import 'package:xyz_project_01/view/goods/g_basket.dart';
import 'package:xyz_project_01/view/goods/g_category.dart';
import 'package:xyz_project_01/view/goods/g_main.dart';
import 'package:xyz_project_01/view/goods/g_map.dart';
import 'package:xyz_project_01/view/goods/g_profill.dart';

class GTabbar extends StatefulWidget {
  final String userid;
  const GTabbar({super.key, required this.userid});

  @override
  State<GTabbar> createState() => _GTabbarState();
}

class _GTabbarState extends State<GTabbar> {
  int _selectedIndex = 0;

  // ✅ 전역 매장 컨트롤러 (main.dart에서 Get.put 해둔 거 찾기)
  final StoreController storeController = Get.find<StoreController>();

  // 탭 화면들
  List<Widget> get _pages => <Widget>[
        GMain(userid: widget.userid), // 0: 홈
        GCategory(userid: widget.userid), // 1: 카테고리
        GBasket(userid: widget.userid), // 2: 장바구니
        GProfill(userid: widget.userid), // 3: 프로필
      ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // 중앙 지도 버튼 눌렀을 때
  void _onMapButtonPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GMap(userid: widget.userid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ body를 Stack으로 감싸서
      //   - 아래: 실제 탭 페이지
      //   - 위: 선택한 매장 바
      body: Stack(
        children: [
          _pages[_selectedIndex],

          // 하단 탭바 바로 위에 선택 매장 표시
          Obx(() {
            final store = storeController.selectedStore.value;

            // ✅ 장바구니 탭(인덱스 2)에서는 전역 매장 바 숨김
            if (store == null || _selectedIndex == 2) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: 0,
              right: 0,
              bottom: 0, // 탭바 바로 위
              child: _buildSelectedStoreBar(store),
            );
          }),
        ],
      ),

      // ✅ 중앙 FloatingActionButton
      //    → 매장이 선택되면 숨김 (겹치지 않게)
      floatingActionButton: Obx(() {
        final hasStore = storeController.selectedStore.value != null;

        if (hasStore) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () => _onMapButtonPressed(context),
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8.0,
          child: const Icon(Icons.place, size: 30),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.menu, 1),

            // 중앙 버튼 자리 (SizedBox -> Padding)
            const Padding(padding: EdgeInsets.only(left: 20, right: 20)),

            _buildNavItem(Icons.shopping_cart, 2),
            _buildNavItem(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  // 탭 아이콘 빌더
  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = index == _selectedIndex;

    return Expanded(
      child: IconButton(
        icon: Icon(icon),
        color: isSelected ? Colors.white : Colors.white70,
        iconSize: 30,
        onPressed: () => _onItemTapped(index),
      ),
    );
  }

  // ✅ 선택한 매장 바 UI
  Widget _buildSelectedStoreBar(Map<String, dynamic> store) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.store_mall_directory, color: Colors.black54),

          // SizedBox -> Padding
          const Padding(padding: EdgeInsets.only(left: 8)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store['name'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                // SizedBox -> Padding
                const Padding(padding: EdgeInsets.only(top: 2)),

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
            onPressed: () => _onMapButtonPressed(context),
            child: const Text(
              '변경',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
