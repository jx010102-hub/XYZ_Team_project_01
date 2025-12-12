import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ⭐️ 추가 임포트: GoodsDetail, Goods 모델
import 'package:xyz_project_01/insert/goods_detail_page.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/example_data.dart';
import 'dart:typed_data'; // Uint8List 사용
import 'package:flutter/services.dart'
    show rootBundle, ByteData; // 추가

// ⭐️ 1. 상품 데이터 모델 정의 (변경 없음)
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

// ⭐️ 2. ExampleData를 Product 모델로 변환하고 가격/제조사를 부여하는 함수 (변경 없음)
List<Product> loadAllProducts() {
  final List<Map<String, dynamic>> rawGoods =
      ExampleData.goods;
  final List<Product> products = [];

  const int unifiedPrice = 150000;
  const String unifiedManufacturer = 'XYZ';

  for (final rawProduct in rawGoods) {
    products.add(
      Product(
        gname: rawProduct['gname'] as String,
        gengname: rawProduct['gengname'] as String,
        gcategory: rawProduct['gcategory'] as String,
        gsize: rawProduct['gsize'] as String,
        gcolor: rawProduct['gcolor'] as String,
        // ExampleData에서 설정된 mainimagePath를 사용합니다.
        mainimagePath:
            rawProduct['mainimagePath'] as String,
        gsumamount: rawProduct['gsumamount'] as int,
        price: unifiedPrice, // ⭐️ 150,000원으로 고정 주입
        manufacturer:
            unifiedManufacturer, // ⭐️ 'XYZ'로 고정 주입
      ),
    );
  }

  return products;
}

// ⭐️ 3. Product 모델을 Goods 모델로 변환하는 함수 추가
// GoodsDetailPage가 요구하는 Goods 객체를 만들기 위해 사용됩니다.
// GCategory에서는 실제 DB 이미지가 아닌 Asset 이미지를 사용하므로,
// GoodsDetail로 넘길 때는 DB 이미지 필드를 null 처리하거나 더미 데이터를 사용합니다.

// Goods 객체의 이미지 필드(mainimage, topimage 등)는 Uint8List 타입이므로,
// GCategory에서 사용하는 String 타입의 mainimagePath를 직접 사용할 수 없습니다.
// 따라서, 이 필드들은 일단 null로 처리합니다. (GoodsDetailPage에서 로딩 시 DB에서 실제 데이터를 로드하도록 되어 있음)

// lib/goods/g_category.dart 파일 내

// lib/goods/g_category.dart 파일 내 _GCategoryState 클래스 내부

// ⭐️ 1. Asset 이미지를 Uint8List로 변환하는 비동기 함수 추가
Future<Uint8List?> _loadAssetToBytes(
  String assetPath,
) async {
  try {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  } catch (e) {
    print(
      "❌ [Image Load Error] Asset을 로드하지 못했습니다: $assetPath, Error: $e",
    );
    return null;
  }
}

// ⭐️ 2. Product 모델을 Goods 모델로 변환하는 함수를 Future<Goods>로 변경
// (기존 convertProductToGoods 함수를 아래 코드로 대체)
Future<Goods> convertProductToGoods(
  Product product,
  String userid,
) async {
  // mainimagePath를 사용하여 Asset 이미지 데이터를 로드
  final Uint8List? mainImageBytes = await _loadAssetToBytes(
    product.mainimagePath,
  );

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

    // ⭐️ 로드된 Uint8List 데이터를 mainimage에 할당
    mainimage: mainImageBytes,

    // 나머지 이미지는 Asset 경로 정보가 없으므로 null 유지
    topimage: null,
    backimage: null,
    sideimage: null,
  );
}

// ⭐️ 3. initState 상단에 rootBundle 사용을 위한 임포트 추가
// (이미 임포트되어 있지 않다면 추가합니다.)

// ------------------------------------------------------------------

class GCategory extends StatefulWidget {
  final String userid;
  const GCategory({super.key, required this.userid});

  @override
  State<GCategory> createState() => _GCategoryState();
}

class _GCategoryState extends State<GCategory> {
  // ⭐️ 4. 상품 데이터 상태 관리
  late List<Product> _allProducts;
  late List<Product> _filteredProducts;

  // 필터 상태 초기값
  String _selectedCategory = '러닝화';
  String _selectedManufacturer = 'XYZ';
  String _selectedPriceRange = '모두'; // 초기 가격 필터를 '모두'로 설정

  // 바텀 시트에서 임시로 사용할 필터 값
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

  // ⭐️ 5. 상품 필터링 로직 (변경 없음)
  void _filterProducts({bool shouldSetState = true}) {
    // ... (필터링 로직 유지) ...
    List<Product> results = _allProducts;

    // 카테고리 필터링
    if (_selectedCategory != '모두') {
      results = results
          .where((p) => p.gcategory == _selectedCategory)
          .toList();
    }

    // 제조사 필터링
    if (_selectedManufacturer != '모두') {
      results = results
          .where(
            (p) => p.manufacturer == _selectedManufacturer,
          )
          .toList();
    }

    // 가격 필터링 로직 (가격 필터가 '모두'가 아닐 때만 적용)
    if (_selectedPriceRange != '모두') {
      if (_selectedPriceRange == '10만원 이하') {
        results = results
            .where((p) => p.price <= 100000)
            .toList();
      } else if (_selectedPriceRange == '100만원 이상') {
        results = results
            .where((p) => p.price >= 1000000)
            .toList();
      } else {
        final RegExp rangeRegex = RegExp(r'(\d+)\~(\d+)만원');
        final match = rangeRegex.firstMatch(
          _selectedPriceRange,
        );
        if (match != null) {
          final int minPrice =
              int.parse(match.group(1)!) * 10000;
          final int maxPrice =
              int.parse(match.group(2)!) * 10000;
          results = results
              .where(
                (p) =>
                    p.price >= minPrice &&
                    p.price < maxPrice,
              )
              .toList();
        }
      }
    }

    if (shouldSetState) {
      setState(() {
        _filteredProducts = results;
      });
    } else {
      _filteredProducts = results;
    }
  }

  // ... (buildFilterTag, buildCurrentFilters 함수 유지) ...

  Widget _buildFilterTag(String text, Color color) {
    if (text == '모두') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          _buildFilterTag(_selectedCategory, Colors.black),
          const SizedBox(width: 8),
          _buildFilterTag(
            _selectedManufacturer,
            Colors.black,
          ),
          const SizedBox(width: 8),
          _buildFilterTag(
            _selectedPriceRange,
            Colors.black,
          ),
          const SizedBox(width: 8),

          Text(
            '${_filteredProducts.length}개 상품',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ⭐️ 6. build 함수 (변경 없음)
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
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              // ⭐️ 필터 바텀 시트 열기
              _showFilterBottomSheet(context);
            },
            icon: const Icon(
              Icons.filter_list,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildCurrentFilters(),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                // ⭐️ [핵심 수정]: 상품 카드에 onTap 제스처 추가
                return GestureDetector(
                  onTap: () async {
                    // <-- async 추가
                    // 로딩 표시 (선택 사항)
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      barrierDismissible: false,
                    );

                    // Product를 Goods로 변환 (await 사용)
                    final Goods goodsData =
                        await convertProductToGoods(
                          product,
                          widget.userid,
                        );

                    Get.back(); // 로딩 창 닫기

                    // GoodsDetailPage로 이동
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

  // ⭐️ 7. 개별 상품 카드 위젯 (디자인 유지)
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
              const SizedBox(height: 5),
              Text(
                product.gname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              const Text(
                "150,000원",
                style: TextStyle(
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

  // ⭐️ 8. 필터 바텀 시트 관련 함수 (변경 없음)
  Widget _buildCategoryChips(StateSetter setStateModal) {
    final List<String> categories = [
      '러닝화',
      '농구화',
      '운동화',
      '스니커즈',
      '모두',
    ];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: categories.map((category) {
        return _buildSelectableChip(
          label: category,
          isSelected: _tempSelectedCategory == category,
          onSelected: (selected) {
            setStateModal(() {
              _tempSelectedCategory = category;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildManufacturerChips(
    StateSetter setStateModal,
  ) {
    final List<String> manufacturers = [
      'XYZ',
      '나이키',
      '아디다스',
      '퓨마',
      '모두',
    ];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: manufacturers.map((manufacturer) {
        return _buildSelectableChip(
          label: manufacturer,
          isSelected:
              _tempSelectedManufacturer == manufacturer,
          onSelected: (selected) {
            setStateModal(() {
              _tempSelectedManufacturer = manufacturer;
            });
          },
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
          onSelected: (selected) {
            setStateModal(() {
              _tempSelectedPriceRange = price;
            });
          },
        );
      }).toList(),
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
            _selectedManufacturer =
                _tempSelectedManufacturer;
            _selectedPriceRange = _tempSelectedPriceRange;
          });

          Get.back();

          _filterProducts();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '적용하기',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    _tempSelectedCategory = _selectedCategory;
    _tempSelectedManufacturer = _selectedManufacturer;
    _tempSelectedPriceRange = _selectedPriceRange;

    Get.bottomSheet(
      StatefulBuilder(
        builder:
            (
              BuildContext context,
              StateSetter setStateModal,
            ) {
              return Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildFilterTitle('카테고리'),
                            _buildCategoryChips(
                              setStateModal,
                            ),
                            const SizedBox(height: 25),

                            _buildFilterTitle('제조사'),
                            _buildManufacturerChips(
                              setStateModal,
                            ),
                            const SizedBox(height: 25),

                            _buildFilterTitle('가격'),
                            _buildPriceChips(setStateModal),
                            const SizedBox(height: 50),
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

  Widget _buildFilterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}
