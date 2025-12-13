import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/view/customer/c_login.dart';
import 'package:xyz_project_01/view/insert/goods_profill_buy_page.dart';

class GProfill extends StatefulWidget {
  final String userid;
  const GProfill({super.key, required this.userid});

  @override
  State<GProfill> createState() => _GProfillState();
}

class _GProfillState extends State<GProfill> {
  // 섹션 사이 굵은 구분선
  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Divider(
        height: 8,
        thickness: 8,
        color: Colors.black12,
      ),
    );
  }

  // 항목 사이 얇은 구분선
  Widget _buildThinDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey,
    );
  }

  // 개별 설정 항목
  Widget _buildSettingItem({
    required String title,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap ??
          () {
            debugPrint('"$title" 항목 클릭됨');
          },
    );
  }

  // 항목 + divider 래퍼
  Widget _buildItemWithDivider({
    required String title,
    VoidCallback? onTap,
    bool showDivider = true,
    Color? textColor,
  }) {
    return Column(
      children: [
        _buildSettingItem(
          title: title,
          onTap: onTap,
          textColor: textColor,
        ),
        if (showDivider) _buildThinDivider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '앱 설정',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              debugPrint('알림 아이콘 클릭됨');
            },
          ),
          const Padding(padding: EdgeInsets.only(right: 10)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionDivider(),

            // --- 첫 번째 섹션 ---
            _buildItemWithDivider(
              title: '주문내역',
              onTap: () {
                Get.to(
                  () => GoodsProfillBuyPage(
                    userId: widget.userid,
                  ),
                );
              },
            ),
            _buildItemWithDivider(title: '알림'),
            _buildItemWithDivider(title: '테마'),
            _buildItemWithDivider(
              title: '언어',
              showDivider: false,
            ),

            _buildSectionDivider(),

            // --- 두 번째 섹션 ---
            _buildItemWithDivider(title: '회사 정보'),
            _buildItemWithDivider(title: '앱 정보'),

            // ✅ 로그아웃 (마지막 → divider 없음)
            _buildItemWithDivider(
              title: '로그아웃',
              showDivider: false,
              textColor: Colors.red,
              onTap: () {
                Get.offAll(() => const CLogin());
              },
            ),

            const Padding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
