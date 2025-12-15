// lib/insert/goods_Info_Page.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/util/message.dart';

class GoodsInfoPage extends StatefulWidget {
  final Goods goods;

  const GoodsInfoPage({super.key, required this.goods});

  @override
  State<GoodsInfoPage> createState() => _GoodsInfoPageState();
}

class _GoodsInfoPageState extends State<GoodsInfoPage> {
  final Message message = Message();

  final List<Uint8List> _infoImages = [];

  @override
  void initState() {
    super.initState();
    _configureImages();
  }

  void _configureImages() {
    final rawImages = <Uint8List?>[
      widget.goods.mainimage,
      widget.goods.topimage,
      widget.goods.backimage,
      widget.goods.sideimage,
    ];

    _infoImages
      ..clear()
      ..addAll(rawImages.whereType<Uint8List>().toSet().toList());

    if (_infoImages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        message.warning('이미지 없음', '${widget.goods.gname}에 DB 이미지가 없습니다.');
      });
    }
  }

  String _imageTitle(int index) {
    if (index == 0) return 'MAIN IMAGE';
    if (index == 1) return 'TOP VIEW';
    return '제품 이미지 ${index + 1}';
  }

  Widget _sectionDivider() {
    return const Divider(
      height: 10,
      thickness: 8,
      color: Color(0xFFF5F5F5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.goods.gname} 제품 상세 정보',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductTitleSection(),
            _sectionDivider(),
            ..._infoImages.asMap().entries.map((entry) {
              return Column(
                children: [
                  _buildInfoSection(
                    title: _imageTitle(entry.key),
                    imageBytes: entry.value,
                  ),
                  _sectionDivider(),
                ],
              );
            }),
            _buildAssetInfoSection(
              title: '사이즈 정보',
              imagePath: 'images/size1.png',
            ),
            _sectionDivider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Container(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPurchaseBar(),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.goods.gengname,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '${NumberFormat('#,###').format(widget.goods.price.round())}원',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) {
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
        ),
      ],
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) {
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
        ),
      ],
    );
  }

  Widget _buildBottomPurchaseBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
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
          ),
        ],
      ),
    );
  }
}
