import 'package:flutter/material.dart';
import 'package:xyz_project_01/goods/g_basket.dart'; // 장바구니
import 'package:xyz_project_01/goods/g_category.dart'; // 카테고리
import 'package:xyz_project_01/goods/g_main.dart'; // 홈
import 'package:xyz_project_01/goods/g_map.dart'; // 지도 (중앙 버튼 액션)
import 'package:xyz_project_01/goods/g_profill.dart'; // 프로필

class GTabbar extends StatefulWidget {
  final String userid;
  const GTabbar({super.key, required this.userid});

  @override
  State<GTabbar> createState() => _GTabbarState();
}

class _GTabbarState extends State<GTabbar> {
  int _selectedIndex = 0;

  // 탭 내용물 리스트 (중앙 버튼은 리스트에 포함하지 않습니다.)
  final List<Widget> _widgetOptions = <Widget>[
    const GMain(), // 0: 홈
    const GCategory(), // 1: 카테고리
    const GBasket(), // 2: 장바구니 (FloatingActionButton 다음 위치)
    const GProfill(), // 3: 프로필
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 중앙 버튼이 눌렸을 때 실행될 함수 (예시로 GMap 페이지로 이동)
  void _onMapButtonPressed(BuildContext context) {
    // Navigator를 사용하여 모달이나 새로운 페이지로 전환할 수 있습니다.
    // 여기서는 간단히 지도 페이지로 이동하는 예시를 사용합니다.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GMap()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 탭의 화면을 보여줍니다.
      body: _widgetOptions.elementAt(_selectedIndex),

      // 1. 중앙 튀어나온 버튼 (FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onMapButtonPressed(context),
        shape: const CircleBorder(),
        backgroundColor: Colors.white, // 이미지와 유사한 연한 회색 배경
        foregroundColor: Colors.black,
        elevation: 8.0,
        child: const Icon(
          Icons.place, // 지도 아이콘
          size: 30,
        ),
      ),

      // 2. 버튼 배치 위치 지정
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // 3. 하단 바 영역 (BottomAppBar)
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape:
            const CircularNotchedRectangle(), // 중앙 버튼을 위한 노치 모양 생성
        notchMargin: 6.0,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // 0: 홈
            _buildNavItem(Icons.home_outlined, 0),
            // 1: 카테고리
            _buildNavItem(Icons.menu, 1),

            // 중앙 FloatingActionButton 공간을 위해 너비 띄우기
            const SizedBox(width: 40),

            // 2: 장바구니 (탭 인덱스 2)
            _buildNavItem(Icons.shopping_cart, 2),
            // 3: 프로필 (탭 인덱스 3)
            _buildNavItem(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  // 탭 항목 위젯 빌더
  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = index == _selectedIndex;

    return Expanded(
      child: IconButton(
        icon: Icon(icon),
        color: isSelected ? Colors.white : Colors.white70,
        iconSize: 30,
        onPressed: () => _onItemTapped(index),
      ),
    );
  }
}
