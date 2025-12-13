// lib/insert/goods_detail_page.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/view/insert/goods_Info_Page.dart';
import 'package:xyz_project_01/view/pay/paypage.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

class GoodsDetailPage extends StatefulWidget {
  final Goods goods;
  final String userid;

  const GoodsDetailPage({
    super.key,
    required this.goods,
    required this.userid,
  });

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  final Message message = Message();

  bool _isLoadingOptions = true;
  int _currentImageIndex = 0;

  Set<String> _availableSizes = {};
  Map<String, int> _availableColorMap = {};

  String? _selectedSize;
  String? _selectedColor;
  int _purchaseQuantity = 1;

  List<Uint8List> _displayImages = [];

  @override
  void initState() {
    super.initState();
    _loadOptionsData();
  }

  // -------------------------
  // Data Load
  // -------------------------
  Future<void> _loadOptionsData() async {
    try {
      final goodsDB = GoodsDatabase();
      final options = await goodsDB.getGoodsByName(widget.goods.gname);

      if (options.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoadingOptions = false);
        debugPrint("❌ [Detail] ${widget.goods.gname} 옵션 데이터 없음");
        return;
      }

      final sizes = <String>{};
      final colorMap = <String, int>{};

      // 이미지 구성 (대표 goods 기준)
      final images = _buildUniqueImagesFromGoods(widget.goods);

      // 옵션 추출
      for (final g in options) {
        sizes.add(g.gsize);
        colorMap.putIfAbsent(g.gcolor, () => _getTempColorHex(g.gcolor));
      }

      if (!mounted) return;

      setState(() {
        _availableSizes = sizes;
        _availableColorMap = colorMap;
        _displayImages = images;

        _setDefaultOptionIfNeeded();

        _isLoadingOptions = false;
      });

      debugPrint("✅ [Detail] ${widget.goods.gname} 옵션 로드 완료");
      debugPrint(
        "✅ [Detail] size=${_availableSizes.length}, color=${_availableColorMap.length}",
      );
    } catch (e) {
      debugPrint('❌ [Detail] 옵션 로드 에러: $e');
      if (!mounted) return;
      setState(() => _isLoadingOptions = false);
      message.error('오류', '옵션 정보를 불러오지 못했습니다.');
    }
  }

  List<Uint8List> _buildUniqueImagesFromGoods(Goods goods) {
    final raw = <Uint8List?>[
      goods.mainimage,
      goods.topimage,
      goods.backimage,
      goods.sideimage,
    ];

    // null 제거 + 중복 제거
    return raw.whereType<Uint8List>().toSet().toList();
  }

  void _setDefaultOptionIfNeeded() {
    _selectedSize ??= _availableSizes.isNotEmpty ? _availableSizes.first : null;
    _selectedColor ??=
        _availableColorMap.isNotEmpty ? _availableColorMap.keys.first : null;
  }

  int _getTempColorHex(String colorName) {
    switch (colorName) {
      case '흰색':
        return 0xFFFFFFFF;
      case '검정색':
        return 0xFF000000;
      case '회색':
        return 0xFFCCCCCC;
      case '시그니쳐 색상':
        return 0xFF3F51B5;
      default:
        return 0xFF808080;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOptions) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.home_outlined, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImageSection(),
            _buildPriceAndNameSection(),

            // ✅ 기존 SizedBox(바닥 여백) 대신 Padding 유지 (UI 동일)
            const Padding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPurchaseBar(context),
    );
  }

  // -------------------------
  // UI
  // -------------------------
  Widget _buildProductImageSection() {
    return SizedBox(
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            itemCount: _displayImages.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.memory(
                _displayImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              );
            },
          ),

          // 좋아요 + 제품상세 버튼
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.thumb_up_alt_outlined, color: Colors.black),
                ),
                const Padding(padding: EdgeInsets.only(left: 10)),
                GestureDetector(
                  onTap: () {
                    Get.to(() => GoodsInfoPage(goods: widget.goods));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: const Text(
                      '제품상세 >',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 페이지 인디케이터
          Positioned(
            bottom: 70,
            child: Row(
              children: List.generate(
                _displayImages.length,
                (index) => _buildIndicator(index == _currentImageIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndNameSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag('주간전체 1위'),
              const Padding(padding: EdgeInsets.only(left: 8)),
              _buildTag('Top 100. ${widget.goods.gcategory}'),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          const Text(
            "150,000원",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          Text(
            widget.goods.gname,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const Padding(padding: EdgeInsets.only(top: 5)),
          Text(
            widget.goods.gengname,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Padding(padding: EdgeInsets.only(left: 5)),
              const Text('4.0', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(' (리뷰 2,000)', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBottomPurchaseBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
            child: const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
          ),
          const Padding(padding: EdgeInsets.only(left: 15)),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showPurchaseOptions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                '구매하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // BottomSheet
  // -------------------------
  void _showPurchaseOptions(BuildContext context) {
    if (_availableSizes.isEmpty || _availableColorMap.isEmpty) {
      message.error('옵션 로드 실패', '상품 옵션 데이터를 로드하지 못했습니다.');
      return;
    }

    _setDefaultOptionIfNeeded();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bc) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            final sheetHeight =
                MediaQuery.of(context).size.height * 0.75 + bottomPadding;

            return Container(
              height: sheetHeight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const Text(
                    '구매하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),

                  _buildOptionProductInfo(widget.goods),
                  const Divider(height: 30),

                  const Text('사이즈', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  SizedBox(
                    height: 80, // ✅ 스크롤 높이 고정이라 SizedBox 유지(필요한 케이스)
                    child: SingleChildScrollView(
                      child: _buildSizeOptions(setModalState),
                    ),
                  ),

                  const Divider(height: 30),

                  const Text('색깔', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  _buildColorOptions(setModalState),

                  if (_selectedSize != null && _selectedColor != null)
                    _buildQuantitySelector(setModalState),

                  const Spacer(),

                  _buildOptionBottomBar(context),

                  Padding(padding: EdgeInsets.only(bottom: bottomPadding)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionProductInfo(Goods goods) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: goods.mainimage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.memory(goods.mainimage!, fit: BoxFit.cover),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goods.gname, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(goods.gengname, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeOptions(StateSetter setModalState) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _availableSizes.map((size) {
        final isSelected = _selectedSize == size;

        return GestureDetector(
          onTap: () => setModalState(() => _selectedSize = size),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.grey.shade800 : Colors.transparent,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorOptions(StateSetter setModalState) {
    return Wrap(
      spacing: 15.0,
      children: _availableColorMap.entries.map((entry) {
        final colorName = entry.key;
        final colorValue = Color(entry.value);
        final isSelected = _selectedColor == colorName;

        final checkColor =
            colorValue.computeLuminance() > 0.5 ? Colors.black : Colors.white;

        return Column(
          children: [
            GestureDetector(
              onTap: () => setModalState(() => _selectedColor = colorName),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorValue,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: isSelected ? 3.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isSelected ? Icon(Icons.check, color: checkColor) : null,
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 5)),
            Text(
              colorName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${_selectedSize ?? '사이즈'} / ${_selectedColor ?? '색상'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () {
                    if (_purchaseQuantity > 1) {
                      setModalState(() => _purchaseQuantity--);
                    }
                  },
                ),
                Text('$_purchaseQuantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => setModalState(() => _purchaseQuantity++),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBottomBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedSize == null || _selectedColor == null) {
                message.warning('옵션 선택', '사이즈와 색상을 모두 선택해 주세요.');
                return;
              }

              Navigator.pop(context);

              message.success(
                '장바구니',
                '${widget.goods.gname} ($_selectedSize/$_selectedColor) $_purchaseQuantity개가 장바구니에 담겼습니다.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              '장바구니 담기',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedSize == null || _selectedColor == null) {
                message.warning('옵션 선택', '사이즈와 색상을 모두 선택해 주세요.');
                return;
              }

              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PayPage(
                    goods: widget.goods,
                    selectedSize: _selectedSize!,
                    selectedColor: _selectedColor!,
                    quantity: _purchaseQuantity,
                    userid: widget.userid,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              '바로 구매하기',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
