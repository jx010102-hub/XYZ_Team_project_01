import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/view/admin_/a_admin_add.dart';
import 'package:xyz_project_01/view/admin_/a_request.dart';
import 'package:xyz_project_01/view/admin_/a_return_request.dart';
import 'package:xyz_project_01/view/admin_/a_stock_status.dart';
import 'package:xyz_project_01/view/customer/c_login.dart';

class AMain extends StatefulWidget {
  const AMain({super.key});

  @override
  State<AMain> createState() => _AMainState();
}

// 관리자 메인 메뉴 Item
class _AdminMenuItem {
  final String text;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.text,
    required this.onTap,
  });
}

class _AMainState extends State<AMain> {
  late final List<_AdminMenuItem> _menus;

  @override
  void initState() {
    super.initState();

    // 메뉴 구성
    _menus = [
      _AdminMenuItem(
        text: '상품 등록',
        onTap: () => Get.to(() => const AdminAdd()),
      ),
      _AdminMenuItem(
        text: '재고 현황',
        onTap: () => Get.to(() => const AStockStatus()),
      ),
      _AdminMenuItem(
        text: '반품 요청',
        onTap: () => Get.to(() => const AReturnRequest()),
      ),
      _AdminMenuItem(
        text: '결제 요청',
        onTap: () => Get.to(() => const ARequst()),
      ),
    ];
  }
  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/xyz_logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: const Text(
                '강남점 직원',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            onPressed: () {
              Get.offAll(() => const CLogin());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _menus
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: _buildAdminButton(
                      text: m.text,
                      onTap: m.onTap,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  } // build

  Widget _buildAdminButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return _PressableAdminButton(text: text, onTap: onTap);
  }
}

// 버튼 눌림 상태
class _PressableAdminButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PressableAdminButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PressableAdminButton> createState() => _PressableAdminButtonState();
}

class _PressableAdminButtonState extends State<_PressableAdminButton> {
  bool _isPressed = false;

  void _setPressed(bool v) {
    if (_isPressed == v) return;
    setState(() => _isPressed = v);
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 350,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isPressed ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  } // build
} // class
