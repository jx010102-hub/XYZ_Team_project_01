// lib/insert/goods_Info_Page.dart 파일 전체 내용

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/model/goods.dart'; // Goods 모델 임포트

class GoodsInfoPage extends StatefulWidget {
  // ⭐️ GoodsDetailPage에서 전달받은 Goods 객체를 받습니다. (필수)
  final Goods goods;
  
  const GoodsInfoPage({super.key, required this.goods});

  @override
  State<GoodsInfoPage> createState() => _GoodsInfoPageState();
}

class _GoodsInfoPageState extends State<GoodsInfoPage> {
  // ⭐️ 상품의 DB 이미지들을 리스트로 구성합니다.
  List<Uint8List> _infoImages = [];

  @override
  void initState() {
    super.initState();
    _configureImages();
  }
  
  // DB에서 전달받은 상품 이미지를 리스트로 구성하는 함수
  void _configureImages() {
    final List<Uint8List?> images = [
      widget.goods.mainimage,
      widget.goods.topimage,
      widget.goods.backimage,
      widget.goods.sideimage,
    ];

    // null이 아닌 유효한 이미지만 필터링하고 중복을 제거합니다.
    _infoImages = images
        .whereType<Uint8List>()
        .toSet()
        .toList();
    
    // 이미지가 전혀 없을 경우 대체 이미지를 추가할 수 있습니다.
    if (_infoImages.isEmpty) {
        // 임시 대체 로직 (필요 시 에러 에셋 추가)
        print("경고: ${widget.goods.gname}에 DB 이미지가 없습니다.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 앱바 배경색 투명/흰색 설정
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.goods.gname} 제품 상세 정보', // 상품 이름 반영
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        automaticallyImplyLeading: false, 
        actions: [
          // 닫기 버튼
          IconButton(
            onPressed: () {
              Get.back(); // 이전 화면으로 돌아가기
            },
            icon: const Icon(
              Icons.close, 
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 제품 기본 정보 섹션
            _buildProductTitleSection(),
            
            const Divider(
              height: 10,
              thickness: 8,
              color: Color(0xFFF5F5F5),
            ), 

            // 2. DB 이미지들을 순서대로 표시
            ..._infoImages.asMap().entries.map((entry) {
              int index = entry.key;
              Uint8List imageBytes = entry.value;
              
              String title = '제품 이미지 ${index + 1}';
              if (index == 0) title = 'MAIN IMAGE';
              if (index == 1) title = 'TOP VIEW';
              
              return Column(
                children: [
                  _buildInfoSection(
                    title: title,
                    imageBytes: imageBytes,
                  ),
                  const Divider(
                    height: 10,
                    thickness: 8,
                    color: Color(0xFFF5F5F5),
                  ),
                ],
              );
            }),
            
            // 3. (임시) 사이즈 정보 섹션 (DB 이미지가 없으므로 하드코딩 에셋 재사용)
            _buildAssetInfoSection(
              title: '사이즈 정보',
              imagePath: 'images/size1.png', // 기존 하드코딩 에셋 사용
            ),

            const Divider(
              height: 10,
              thickness: 8,
              color: Color(0xFFF5F5F5),
            ),

            // 하단 NavBar와 겹치지 않도록 여백 추가
            const SizedBox(height: 100),
          ],
        ),
      ),

      // 하단 고정 구매 버튼 바
      bottomNavigationBar: _buildBottomPurchaseBar(),
    );
  }

  // ⭐️ 제품명 및 간략 정보 표시 섹션
  Widget _buildProductTitleSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.goods.gname,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.goods.gengname,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          // ⭐️ 가격은 고정된 150,000원으로 표시
          const Text(
            "150,000원",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }


  // ⭐️ 상세 정보 이미지 섹션 위젯 (DB 이미지 사용)
  Widget _buildInfoSection({
    required String title,
    required Uint8List imageBytes,
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

        // DB에서 가져온 Uint8List 이미지 표시
        Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text(
                '이미지 로드 실패 (DB)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ],
    );
  }
  
  // ⭐️ 상세 정보 이미지 섹션 위젯 (하드코딩된 에셋 경로 사용 - size1.png 등)
  Widget _buildAssetInfoSection({
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

        // 에셋 경로 이미지 표시
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Text(
                '이미지 로드 실패: $imagePath',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ],
    );
  }


  // ⭐️ 하단 고정 구매 버튼 바
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
                // 제품 정보 페이지에서 '구매하기' 버튼을 누르면
                // GoodsDetailPage로 돌아가서 옵션 선택 바텀 시트를 띄웁니다.
                Get.back(); 
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