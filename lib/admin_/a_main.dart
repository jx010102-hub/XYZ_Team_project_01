import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/admin_/a_admin_add.dart';
import 'package:xyz_project_01/admin_/a_return_request.dart';
import 'package:xyz_project_01/admin_/a_stock_status.dart';

class AMain extends StatefulWidget {
  const AMain({super.key});

  @override
  State<AMain> createState() => _AMainState();
}

class _AMainState extends State<AMain> {
  // ⭐️⭐️⭐️ 수정된 _buttons 정의: 'page' 대신 'action'에 이동 함수를 할당합니다. ⭐️⭐️⭐️
  final List<Map<String, dynamic>> _buttons = [
    // 'action' 필드에 Get.to()를 실행하는 함수를 직접 할당
    {
      'text': '상품 등록',
      'action': () => Get.to(() => const AdminAdd()),
    },
    {
      'text': '재고 현황',
      'action': () => Get.to(() => const AStockStatus()),
    }, // 임시 함수
    {
      'text': '반품 요청',
      'action': () => Get.to(() => const AReturnRequest()),
    }, // 임시 함수
    {
      'text': '결제 요청',
      'action': () => Get.snackbar('알림', '결제 요청 페이지 준비 중'),
    }, // 임시 함수
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ... (App Bar 내용 생략) ...
        // 로고와 '강남점 직원' 텍스트
        title: Row(
          children: [
            Image.asset(
              'images/xyz_logo.png', // 이미지 경로 확인 필요
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              '강남점 직원',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 'page' 대신 'action'을 호출하도록 변경
              ..._buttons.map((btn) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: _buildAdminButton(
                    text: btn['text'] as String,
                    // 버튼의 onTap에서 'action' 필드에 할당된 함수를 호출합니다.
                    onTap: btn['action'] as VoidCallback,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // ... (이하 _buildAdminButton 및 _PressableAdminButton 코드는 동일) ...
  // 버튼 위젯을 생성하고 상태 변화를 적용하기 위해 별도의 StatefulWidget으로 분리
  Widget _buildAdminButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return _PressableAdminButton(text: text, onTap: onTap);
  }
}

// 버튼 클릭 시 색상 변화를 위한 StatefulWidget (이전 코드와 동일)
class _PressableAdminButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PressableAdminButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PressableAdminButton> createState() =>
      _PressableAdminButtonState();
}

class _PressableAdminButtonState
    extends State<_PressableAdminButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 버튼이 눌리기 시작했을 때
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      // 버튼에서 손을 떼거나 취소되었을 때
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap(); // 할당된 action 함수 실행
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 350,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.black
              : Colors.grey[100],
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
  }
}
