import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/view/insert/goods_detail_page.dart';
import 'package:xyz_project_01/vm/database/example_data.dart';


  // Product 모델
class Product {
  final String gname;
  final String gengname;
  final String gcategory;
  final String gsize;
  final String gcolor;
  final String mainimagePath;
  final int gsumamount;
  final int price;
  final String manufacturer;

  Product({
    required this.gname,
    required this.gengname,
    required this.gcategory,
    required this.gsize,
    required this.gcolor,
    required this.mainimagePath,
    required this.gsumamount,
    required this.price,
    required this.manufacturer,
  });
}

  // ExampleData -> Product 변환
  List<Product> loadAllProducts() {
    final List<Map<String, dynamic>> rawGoods = ExampleData.goods;
    final List<Product> products = [];

    const String unifiedManufacturer = 'XYZ';

    // ✅ gname 기준 중복 제거
    final Set<String> seenNames = {};

    for (final rawProduct in rawGoods) {
      final String gname = rawProduct['gname'] as String;

      // 이미 같은 이름이 들어갔으면 스킵 (사이즈/색상 다른 행 제거)
      if (seenNames.contains(gname)) continue;
      seenNames.add(gname);

      products.add(
        Product(
          gname: gname,
          gengname: rawProduct['gengname'] as String,
          gcategory: rawProduct['gcategory'] as String,

          // 대표로 1개만 보여줄 거라 첫 행의 값만 사용됨
          gsize: rawProduct['gsize'] as String,
          gcolor: rawProduct['gcolor'] as String,

          mainimagePath: rawProduct['mainimagePath'] as String,
          gsumamount: rawProduct['gsumamount'] as int,
          price: (rawProduct['price'] as num).toInt(),
          manufacturer: rawProduct['manufacturer'] as String? ?? unifiedManufacturer,
        ),
      );
    }

    return products;
  }

// Page
class GCategory extends StatefulWidget {
  final String userid;
  const GCategory({super.key, required this.userid});
  
  @override
  State<GCategory> createState() => _GCategoryState();
}

class _GCategoryState extends State<GCategory> {
  late final List<Product> _allProducts;
  late List<Product> _filteredProducts;
  final NumberFormat _currencyFormatter = NumberFormat('#,###');
  String _formatCurrency(int amount) => '${_currencyFormatter.format(amount)}원';

  // 필터 상태 초기값
  String _selectedCategory = '러닝화';
  String _selectedManufacturer = 'XYZ';
  String _selectedPriceRange = '모두';

  // 바텀시트 임시 필터
  late String _tempSelectedCategory;
  late String _tempSelectedManufacturer;
  late String _tempSelectedPriceRange;

  @override
  void initState() {
    super.initState();

    _allProducts = loadAllProducts();

    _tempSelectedCategory = _selectedCategory;
    _tempSelectedManufacturer = _selectedManufacturer;
    _tempSelectedPriceRange = _selectedPriceRange;

    _filterProducts(shouldSetState: false);
  }

  // Asset -> Bytes
  Future<Uint8List?> _loadAssetToBytes(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {

      print("❌ [Image Load Error] Asset 로드 실패: $assetPath, Error: $e");
      return null;
    }
  }

  // Product -> Goods 변환
  Future<Goods> _convertProductToGoods(Product product) async {
    final Uint8List? mainImageBytes = await _loadAssetToBytes(product.mainimagePath);

    return Goods(
      gseq: null,
      gsumamount: product.gsumamount,
      gname: product.gname,
      gengname: product.gengname,
      gcategory: product.gcategory,
      gsize: product.gsize,
      gcolor: product.gcolor,
      price: product.price.toDouble(),
      manufacturer: product.manufacturer,
      mainimage: mainImageBytes,
      topimage: null,
      backimage: null,
      sideimage: null,
    );
  }

  // 필터링
  void _filterProducts({bool shouldSetState = true}) {
    List<Product> results = _allProducts;

    if (_selectedCategory != '모두') {
      results = results.where((p) => p.gcategory == _selectedCategory).toList();
    }

    if (_selectedManufacturer != '모두') {
      results = results.where((p) => p.manufacturer == _selectedManufacturer).toList();
    }

    if (_selectedPriceRange != '모두') {
      if (_selectedPriceRange == '10만원 이하') {
        results = results.where((p) => p.price <= 100000).toList();
      } else if (_selectedPriceRange == '100만원 이상') {
        results = results.where((p) => p.price >= 1000000).toList();
      } else {
        final RegExp rangeRegex = RegExp(r'(\d+)\~(\d+)만원');
        final match = rangeRegex.firstMatch(_selectedPriceRange);
        if (match != null) {
          final int minPrice = int.parse(match.group(1)!) * 10000;
          final int maxPrice = int.parse(match.group(2)!) * 10000;
          results = results.where((p) => p.price >= minPrice && p.price < maxPrice).toList();
        }
      }
    }

    if (shouldSetState) {
      setState(() => _filteredProducts = results);
    } else {
      _filteredProducts = results;
    }
  }

  Widget _buildFilterTag(String text, Color color) {
    if (text == '모두') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrentFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        children: [
          _buildFilterTag(_selectedCategory, Colors.black),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildFilterTag(_selectedManufacturer, Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildFilterTag(_selectedPriceRange, Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${_filteredProducts.length}개 상품',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png',
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Icons.filter_list, color: Colors.black),
          ),
          const Padding(padding: EdgeInsets.only(right: 10)),
        ],
      ),
      body: Column(
        children: [
          _buildCurrentFilters(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];

                return GestureDetector(
                  onTap: () async {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    final Goods goodsData = await _convertProductToGoods(product);

                    Get.back();

                    Get.to(
                      GoodsDetailPage(
                        goods: goodsData,
                        userid: widget.userid,
                      ),
                    );
                  },
                  child: _buildProductCard(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 상품 카드
  Widget _buildProductCard(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                product.mainimagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text(product.gname));
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.gcategory,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              Text(
                product.gname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              Text(
                _formatCurrency(product.price),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // BottomSheet
  void _showFilterBottomSheet(BuildContext context) {
    _tempSelectedCategory = _selectedCategory;
    _tempSelectedManufacturer = _selectedManufacturer;
    _tempSelectedPriceRange = _selectedPriceRange;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterTitle('카테고리'),
                        _buildCategoryChips(setStateModal),
                        const Padding(padding: EdgeInsets.only(top: 25)),
                        _buildFilterTitle('제조사'),
                        _buildManufacturerChips(setStateModal),
                        const Padding(padding: EdgeInsets.only(top: 25)),
                        _buildFilterTitle('가격'),
                        _buildPriceChips(setStateModal),
                        const Padding(padding: EdgeInsets.only(top: 50)),
                      ],
                    ),
                  ),
                ),
                _buildApplyButton(),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = _tempSelectedCategory;
            _selectedManufacturer = _tempSelectedManufacturer;
            _selectedPriceRange = _tempSelectedPriceRange;
          });

          Get.back();
          _filterProducts();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          '적용하기',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Chips
  Widget _buildCategoryChips(StateSetter setStateModal) {
    final List<String> categories = ['러닝화', '농구화', '운동화', '스니커즈', '모두'];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: categories.map((category) {
        return _buildSelectableChip(
          label: category,
          isSelected: _tempSelectedCategory == category,
          onSelected: (_) => setStateModal(() => _tempSelectedCategory = category),
        );
      }).toList(),
    );
  }

  Widget _buildManufacturerChips(StateSetter setStateModal) {
    final List<String> manufacturers = ['XYZ', '나이키', '아디다스', '퓨마', '모두'];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: manufacturers.map((manufacturer) {
        return _buildSelectableChip(
          label: manufacturer,
          isSelected: _tempSelectedManufacturer == manufacturer,
          onSelected: (_) => setStateModal(() => _tempSelectedManufacturer = manufacturer),
        );
      }).toList(),
    );
  }

  Widget _buildPriceChips(StateSetter setStateModal) {
    final List<String> prices = [
      '모두',
      '10만원 이하',
      '10~20만원',
      '20~30만원',
      '30~50만원',
      '50~100만원',
      '100만원 이상',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: prices.map((price) {
        return _buildSelectableChip(
          label: price,
          isSelected: _tempSelectedPriceRange == price,
          onSelected: (_) => setStateModal(() => _tempSelectedPriceRange = price),
        );
      }).toList(),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.black,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}
