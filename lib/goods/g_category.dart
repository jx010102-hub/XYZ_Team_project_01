import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/vm/database/example_data.dart'; // 데이터베이스 파일은 건드리지 않음

// ⭐️ 1. 상품 데이터 모델 정의 (변경 없음)
class Product {
  final String gname;
  final String gengname;
  final String gcategory;
  final String gsize;
  final String gcolor;
  final String mainimagePath;
  final int gsumamount;
  final int price; // 임의로 추가된 가격 필드
  final String manufacturer; // 임의로 추가된 제조사 필드

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

// ⭐️ 2. ExampleData를 Product 모델로 변환하고 가격/제조사를 부여하는 함수 (수정됨)
List<Product> loadAllProducts() {
  final List<Map<String, dynamic>> rawGoods =
      ExampleData.goods;
  final List<Product> products = [];

  // ⭐️ [핵심 수정 1]: 모든 상품의 가격을 150,000원으로 통일합니다.
  const int unifiedPrice = 150000;

  // ⭐️ [핵심 수정 2]: 모든 상품의 제조사를 'XYZ'로 통일합니다.
  const String unifiedManufacturer = 'XYZ';

  for (final rawProduct in rawGoods) {
    // 필수 데이터가 포함되어 있다고 가정하고 Product 객체 생성
    products.add(
      Product(
        gname: rawProduct['gname'] as String,
        gengname: rawProduct['gengname'] as String,
        gcategory: rawProduct['gcategory'] as String,
        gsize: rawProduct['gsize'] as String,
        gcolor: rawProduct['gcolor'] as String,
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
// ------------------------------------------------------------------

class GCategory extends StatefulWidget {
  final String userid;
  const GCategory({super.key, required this.userid});

  @override
  State<GCategory> createState() => _GCategoryState();
}

class _GCategoryState extends State<GCategory> {
  // ⭐️ 3. 상품 데이터 상태 관리
  late List<Product> _allProducts;
  late List<Product> _filteredProducts;

  // 필터 상태 초기값
  String _selectedCategory = '러닝화';
  String _selectedManufacturer = 'XYZ';
  String _selectedPriceRange =
      '모두'; // ⭐️ 초기 가격 필터를 '모두'로 설정

  // 바텀 시트에서 임시로 사용할 필터 값
  late String _tempSelectedCategory;
  late String _tempSelectedManufacturer;
  late String _tempSelectedPriceRange;

  @override
  void initState() {
    super.initState();
    // ⭐️ 모든 상품 로드
    _allProducts = loadAllProducts();

    // 초기 필터 상태 설정
    _tempSelectedCategory = _selectedCategory;
    _tempSelectedManufacturer = _selectedManufacturer;
    _tempSelectedPriceRange = _selectedPriceRange;

    // ⭐️ 초기 필터링 적용
    _filterProducts(shouldSetState: false);
  }

  // ⭐️ 4. 상품 필터링 로직 (가격 필터 로직 수정)
  void _filterProducts({bool shouldSetState = true}) {
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

    // ⭐️ [핵심 수정 3]: 가격 필터링 로직 (가격 필터가 '모두'가 아닐 때만 적용)
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

  // ⭐️ 현재 적용된 필터를 보여주는 작은 태그 위젯
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

  // ⭐️ 현재 적용된 필터 표시 및 상품 개수 위젯
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

          // ⭐️ 필터링된 상품 개수 표시
          Text(
            '${_filteredProducts.length}개 상품',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ⭐️ 5. build 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ... (앱바 로직 유지) ...
        title: Image.asset(
          'images/xyz_logo.png', // 실제 사용하는 로고 경로로 변경
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ... (검색, 알림 아이콘) ...
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

          // ⭐️ 필터링된 상품 목록을 보여주는 GridView
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
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️ 개별 상품 카드 위젯 (Product 객체 사용)
  // lib/goods/g_category.dart 파일 내의 _GCategoryState 클래스 내부

  // ⭐️ 개별 상품 카드 위젯 (Product 객체 사용) - 요청하신 디자인으로 변경
  Widget _buildProductCard(Product product) {
    // ⚠️ 가격 포맷팅 로직은 이제 사용하지 않으며, 가격은 "150,000원"으로 고정 표시됩니다.

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
                product.mainimagePath, // 'mainX.png' 경로 사용
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text(product.gname));
                },
              ),
            ),
          ),
        ),

        // ⭐️ [수정된 부분]: 텍스트 정보 영역 (요청하신 디자인으로 변경)
        Padding(
          padding: const EdgeInsets.all(
            10.0,
          ), // GridView builder padding과 맞춰 10.0으로 조정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.gcategory, // 카테고리 사용
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product.gname, // 제품명 사용
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              // 금액 표시: "150,000원"으로 고정
              const Text(
                "150,000원", // ⭐️ 하드코딩된 가격 사용
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // ⭐️ [수정 끝]
      ],
    );
  }

  // ... 나머지 GCategoryState 코드는 이전과 동일합니다.

  // -----------------------------------------------------------
  // ⭐️ 필터 바텀 시트 관련 함수
  // -----------------------------------------------------------

  // ⭐️ 카테고리 칩 위젯 그룹 (DB gcategory 기준 + '모두' 추가)
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

  // ⭐️ 제조사 칩 위젯 그룹
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

  // ⭐️ 가격 칩 위젯 그룹 (가장 상단에 '모두' 추가)
  Widget _buildPriceChips(StateSetter setStateModal) {
    final List<String> prices = [
      '모두', // ⭐️ '모두' 옵션 추가됨
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

  // ⭐️ 하단 적용 버튼 위젯
  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 1. 임시 필터 값을 실제 필터 상태 변수에 적용
          setState(() {
            _selectedCategory = _tempSelectedCategory;
            _selectedManufacturer =
                _tempSelectedManufacturer;
            _selectedPriceRange = _tempSelectedPriceRange;
          });

          // 2. 바텀 시트 닫기
          Get.back();

          // 3. 필터링 로직 호출 및 메인 화면 새로고침
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

  // ⭐️ 필터 설정을 위한 모달 바텀 시트 (재사용 유지)
  void _showFilterBottomSheet(BuildContext context) {
    // 바텀 시트를 열 때 현재 선택된 값을 임시 변수에 복사
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
                    // 닫기 핸들
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

                    // 필터 내용 (스크롤 가능)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // 1. 카테고리 섹션
                            _buildFilterTitle('카테고리'),
                            _buildCategoryChips(
                              setStateModal,
                            ),
                            const SizedBox(height: 25),

                            // 2. 제조사 섹션
                            _buildFilterTitle('제조사'),
                            _buildManufacturerChips(
                              setStateModal,
                            ),
                            const SizedBox(height: 25),

                            // 3. 가격 섹션
                            _buildFilterTitle('가격'),
                            _buildPriceChips(setStateModal),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),

                    // 4. 하단 적용 버튼
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
