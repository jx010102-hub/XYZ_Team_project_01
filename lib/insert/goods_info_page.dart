import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Get.back() 또는 Get.to() 사용을 위해 추가

class GoodsInfoPage extends StatefulWidget {
  // 만약 GoodsDetailPage에서 데이터를 전달받았다면 final Goods? goods; 추가
  const GoodsInfoPage({super.key});

  @override
  State<GoodsInfoPage> createState() =>
      _GoodsInfoPageState();
}

class _GoodsInfoPageState extends State<GoodsInfoPage> {
  // ⭐️ 이미지 에셋 경로 정의 (사용자 제공 파일 이름 기반)
  final Map<String, String> _infoImages = {
    '사이즈': 'images/size1.png',
    'MAIN': 'images/main1.png',
    'TOP': 'images/top1.png',
    'BACK': 'images/back1.png',
    'SIDE': 'images/side1.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 앱바 배경색 투명/흰색 설정
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        actions: [
          // ❌ 닫기 버튼 (사용자 요청 아이콘)
          IconButton(
            onPressed: () {
              // Get.back()을 사용하여 이전 화면으로 돌아갑니다. (Get 패키지 사용 가정)
              Get.back();
            },
            icon: const Icon(
              Icons.close, // 닫기 아이콘
              color: Colors.black,
            ),
          ),
        ],
      ),

      // 스크롤 가능하도록 SingleChildScrollView 사용
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 사이즈 정보 섹션 (size1.png)
            _buildInfoSection(
              title: '사이즈', // 이미지에는 KM, 225... 로 표시된 표
              imagePath: _infoImages['사이즈']!,
              showTitle:
                  false, // 이미지 자체가 제목 역할을 하므로 제목 텍스트는 생략
            ),

            const Divider(
              height: 10,
              thickness: 8,
              color: Color(0xFFF5F5F5),
            ), // 섹션 구분선
            // 2. MAIN 이미지 섹션 (main1.png)
            _buildInfoSection(
              title: 'MAIN',
              imagePath: _infoImages['MAIN']!,
            ),

            const Divider(
              height: 10,
              thickness: 8,
              color: Color(0xFFF5F5F5),
            ),

            // 3. TOP 이미지 섹션 (top1.png)
            _buildInfoSection(
              title: 'TOP',
              imagePath: _infoImages['TOP']!,
            ),

            const Divider(
              height: 10,
              thickness: 8,
              color: Color(0xFFF5F5F5),
            ),

            // 4. BACK 이미지 섹션 (back1.png)
            _buildInfoSection(
              title: 'BACK',
              imagePath: _infoImages['BACK']!,
            ),

            const Divider(
              height: 10,
              thickness: 8,
              color: Color(0xFFF5F5F5),
            ),

            // 5. SIDE (측면) 정보를 위한 구분선/여백 (side1.png를 위해)
            _buildInfoSection(
              title: 'SIDE',
              imagePath: _infoImages['SIDE']!,
            ),

            // 하단 NavBar와 겹치지 않도록 여백 추가
            const SizedBox(height: 100),
          ],
        ),
      ),

      // 하단 고정 구매 버튼 바 (GoodsDetailPage의 UI 재사용 가정)
      bottomNavigationBar: _buildBottomPurchaseBar(),
    );
  }

  // ⭐️ 상세 정보 이미지 섹션 위젯
  Widget _buildInfoSection({
    required String title,
    required String imagePath,
    bool showTitle = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // 이미지 표시 (가로 전체 채우기)
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          // 이미지 로드 실패 시 대체 UI
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Text(
                '이미지 로드 실패: $imagePath\n(에셋 경로를 확인하세요)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ],
    );
  }

  // ⭐️ 하단 고정 구매 버튼 바 (GoodsDetailPage의 UI와 동일하게 구성)
  Widget _buildBottomPurchaseBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          // 1. 좋아요 버튼 (좌측)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 15),

          // 2. 구매하기 버튼 (우측)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: 실제 구매 로직 또는 옵션 선택 바텀 시트 호출 로직 추가
                // 현재 페이지는 정보만 보여주므로, 만약 여기서 구매를 원하면 GoodsDetailPage로 돌아가거나,
                // 아니면 모달을 띄워서 옵션을 선택하게 해야 합니다.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '구매하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
