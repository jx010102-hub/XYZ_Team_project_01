import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/insert/goods_profill_buy_page.dart';

class GProfill extends StatefulWidget {
  final String userid;
  const GProfill({super.key, required this.userid});

  @override
  State<GProfill> createState() => _GProfillState();
}

class _GProfillState extends State<GProfill> {
  // 개별 설정 항목을 빌드하는 함수
  Widget _buildSettingItem({
    required String title,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap:
              onTap ??
              () {
                // 기본 동작: 어떤 항목이 클릭되었는지 콘솔에 출력
                print('"$title" 항목 클릭됨');
              },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
        ),
        // 항목 간 구분선 (알림, 테마, 언어 사이에 사용)
        if (title != '주문내역' &&
            title != '알림' &&
            title != '테마' &&
            title != '언어' &&
            title != '회사 정보' &&
            title != '앱 정보')
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
      ],
    );
  }

  // 섹션 구분선 (굵은 회색 선)을 빌드하는 함수
  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 0,
      ),
      child: Divider(
        height: 8, // 구분선 자체의 높이 (두께)
        thickness: 8, // 구분선 자체의 두께
        color: Colors.black12, // 연한 회색으로 섹션을 구분
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // '앱 설정' 타이틀
        title: const Text(
          '앱 설정',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // AppBar 아래 그림자 제거
        automaticallyImplyLeading:
            false, // 뒤로가기 버튼 자동 생성 방지 (탭바 내부에 있으므로)
        // 오른쪽 상단 종 모양 아이콘
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              print('알림 아이콘 클릭됨');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 이미지의 굵은 상단 구분선
            _buildSectionDivider(),

            // --- 첫 번째 섹션 ---
            _buildSettingItem(
              title: '주문내역',
              onTap: () {
                // ⭐️ GoodsProfillBuyPage로 이동 시 userid 전달
                Get.to(
                  () => GoodsProfillBuyPage(
                    userId: widget.userid, // GProfill이 받은 userid를 전달
                  ),
                );
              },
            ),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            _buildSettingItem(title: '알림'),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            _buildSettingItem(title: '테마'),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            _buildSettingItem(title: '언어'),

            // --- 두 번째 섹션 구분선 ---
            _buildSectionDivider(),

            // --- 두 번째 섹션 ---
            _buildSettingItem(title: '회사 정보'),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            _buildSettingItem(title: '앱 정보'),

            // 나머지 여백
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}