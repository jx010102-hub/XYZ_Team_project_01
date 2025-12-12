import 'package:flutter/material.dart';
import 'package:get/get.dart';
// 데이터베이스 및 모델 import
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

// 재고 현황 페이지
class AStockStatus extends StatefulWidget {
  const AStockStatus({super.key});

  @override
  State<AStockStatus> createState() => _AStockStatusState();
}

class _AStockStatusState extends State<AStockStatus> {
  // DB 핸들러 인스턴스
  final GoodsDatabase _goodsDatabase = GoodsDatabase();

  // 탭 상태: 0 = 일자별, 1 = 제품별
  int _selectedTab = 1; // 기본을 '제품별'로 설정하여 DB 연동 결과를 바로 표시

  // 드롭다운 및 텍스트 필드 상태
  String? _selectedMonth = 'Sep';
  String? _selectedYear = '2025';
  String? _selectedManufacturer;
  String? _selectedProductName;
  final TextEditingController _productCodeController =
      TextEditingController();

  // --- 상태 데이터 (DB 연동) ---
  List<Goods> _representativeGoodsList =
      []; // 전체 상품명 (대표 상품) 목록
  Goods? _selectedGoods; // 현재 선택된 대표 상품 (제품별 현황 카드용)
  List<Goods> _goodsOptions =
      []; // 선택된 대표 상품의 모든 옵션 (사이즈/색상)
  String? _selectedSize; // 현재 선택된 사이즈
  String? _selectedColor; // 현재 선택된 색상
  Goods? _selectedVariant; // 현재 선택된 옵션의 Goods 객체

  // --- 더미 데이터 (제조사는 임시로 사용) ---
  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final List<String> _years = ['2023', '2024', '2025'];
  final List<String> _manufacturers = [
    '나이키',
    '아디다스',
    'XYZ',
  ]; // DB 필터링 미구현, 임시 데이터

  @override
  void initState() {
    super.initState();
    _fetchRepresentativeGoods();
    // 제품코드 초기값 설정 (선택된 상품의 gseq를 표시하도록 할 수 있으나, 여기서는 초기 빈값으로 둠)
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
  }

  // --- DB 호출 함수 ---

  // 1. 대표 상품 목록 불러오기 (제품별 현황 드롭다운용)
  Future<void> _fetchRepresentativeGoods() async {
    final goodsList = await _goodsDatabase
        .queryRepresentativeGoods();
    setState(() {
      _representativeGoodsList = goodsList;
      // 첫 번째 상품을 기본 선택값으로 설정
      if (goodsList.isNotEmpty) {
        _selectedProductName = goodsList.first.gname;
        _selectedManufacturer = 'XYZ'; // 임시 제조사 설정
        _fetchGoodsOptions(goodsList.first.gname);
      }
    });
  }

  // 2. 선택된 제품명의 모든 옵션 (사이즈/색상) 불러오기
  Future<void> _fetchGoodsOptions(String gname) async {
    if (gname.isEmpty) return;

    final options = await _goodsDatabase.getGoodsByName(
      gname,
    );
    setState(() {
      _goodsOptions = options;
      if (options.isNotEmpty) {
        _selectedGoods =
            options.first; // 대표 상품 정보 (이름, 영문 이름, 코드)
        _productCodeController.text = _selectedGoods!.gseq
            .toString(); // DB seq를 제품 코드로 임시 사용

        // 첫 번째 옵션을 기본 선택값으로 설정
        _selectedSize = options.first.gsize;
        _selectedColor = options.first.gcolor;
        _selectedVariant = options.first;
      } else {
        _selectedGoods = null;
        _selectedSize = null;
        _selectedColor = null;
        _selectedVariant = null;
      }
    });
  }

  // 3. 특정 옵션 (사이즈+색상) 선택 시 재고 정보 업데이트
  Future<void> _selectGoodsVariant(
    String size,
    String color,
  ) async {
    if (_selectedProductName == null) return;

    final variant = await _goodsDatabase.getGoodsVariant(
      gname: _selectedProductName!,
      gsize: size,
      gcolor: color,
    );

    setState(() {
      _selectedSize = size;
      _selectedColor = color;
      _selectedVariant = variant;
    });
  }

  // 4. 발주 신청 (재고 증가 로직)
  Future<void> _processOrder(int gseq, int quantity) async {
    final result = await _goodsDatabase.updateGoodsQuantity(
      gseq: gseq,
      quantityChange: quantity,
    );

    if (result > 0) {
      Get.snackbar(
        '성공',
        '재고가 $quantity 만큼 증가했습니다.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // DB 업데이트 후 화면 데이터 갱신
      await _fetchGoodsOptions(_selectedProductName!);
      await _selectGoodsVariant(
        _selectedSize!,
        _selectedColor!,
      );
    } else {
      Get.snackbar(
        '실패',
        '재고 업데이트에 실패했습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '재고 현황',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 탭 전환 및 검색 필터 영역
            _buildFilterAndSearchSection(),
            const Divider(height: 1, thickness: 1),

            // 2. 검색어 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildProductCodeSearch(),
            ),
            const Divider(height: 1, thickness: 1),

            // 3. 재고 상세 현황 카드
            if (_selectedGoods != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStockDetailCard(
                  _selectedGoods!,
                ),
              ),

            // 4. 재고 현황 상세 정보 (사이즈, 색상, 그래프)
            if (_selectedVariant != null)
              _buildStockInfoSection(),

            if (_selectedGoods == null && _selectedTab == 1)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('조회할 상품을 선택해주세요.'),
                ),
              ),

            // 5. 발주하기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedVariant != null
                      ? _showOrderBottomSheet
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                  child: const Text(
                    '발주하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 위젯 구성 함수 ---

  // 1. 탭 전환 및 필터 영역
  Widget _buildFilterAndSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTabButton(text: '일자별 현황', index: 0),
              const SizedBox(width: 10),
              _buildTabButton(text: '제품별 현황', index: 1),
            ],
          ),
          const SizedBox(height: 15),

          // 동적 필터 영역
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              if (_selectedTab == 0) // 일자별 현황 필터
              ...[
                _buildDropdown(
                  label: '월별',
                  value: _selectedMonth,
                  items: _months,
                  onChanged: (val) =>
                      setState(() => _selectedMonth = val),
                ),
                _buildDropdown(
                  label: '연도',
                  value: _selectedYear,
                  items: _years,
                  onChanged: (val) =>
                      setState(() => _selectedYear = val),
                ),
              ] else // 제품별 현황 필터
              ...[
                _buildDropdown(
                  label: '제조사',
                  value: _selectedManufacturer,
                  items: _manufacturers,
                  onChanged: (val) => setState(
                    () => _selectedManufacturer = val,
                  ),
                ),
                _buildGoodsNameDropdown(), // DB 연동 제품명 드롭다운
              ],
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  // 제품명 드롭다운 (DB에서 가져온 데이터 사용)
  Widget _buildGoodsNameDropdown() {
    // DB에서 가져온 상품 이름만 추출
    final productNames = _representativeGoodsList
        .map((g) => g.gname)
        .toList();

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: DropdownButtonFormField<String>(
          value: _selectedProductName,
          items: productNames.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedProductName = newValue;
              });
              _fetchGoodsOptions(
                newValue,
              ); // 선택된 상품명으로 옵션 재조회
            }
          },
          decoration: const InputDecoration(
            labelText: '제품명',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  // 탭 버튼 위젯
  Widget _buildTabButton({
    required String text,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _selectedTab == index
              ? Colors.black
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedTab == index
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 드롭다운 위젯 (월별, 연도, 제조사)
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  // 2. 제품 코드 검색 필드
  Widget _buildProductCodeSearch() {
    return TextField(
      controller: _productCodeController,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),
        hintText: '제품코드를 입력하세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
      ),
      readOnly: true, // 제품 코드는 DB에서 가져온 값을 표시하므로 읽기 전용
    );
  }

  // 3. 재고 상세 현황 카드 (제품 정보)
  Widget _buildStockDetailCard(Goods goods) {
    // 선택된 대표 상품의 정보를 표시
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '제품코드 : ${goods.gseq.toString()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Image.asset(
                (goods.mainimage ?? 'images/logo.png')
                    .toString(), // DB의 mainimage 사용
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    goods.gname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    goods.gengname ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. 재고 현황 상세 정보 (사이즈, 색상, 그래프)
  Widget _buildStockInfoSection() {
    // 모든 옵션에서 사이즈와 색상 목록 추출
    final uniqueSizes = _goodsOptions
        .map((g) => g.gsize)
        .toSet()
        .toList();
    final uniqueColors = _goodsOptions
        .map((g) => g.gcolor)
        .toSet()
        .toList();

    // 현재 선택된 옵션의 재고 정보
    final int currentStock =
        _selectedVariant?.gsumamount ?? 0;
    // 임시로 최대 재고를 100으로 가정 (실제로는 상품별 최대 재고 필드가 필요할 수 있음)
    const int maxStock = 100;
    final double stockRatio = currentStock / maxStock;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사이즈 태그
          const Text(
            'size',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: uniqueSizes
                .map(
                  (size) => _buildOptionTag(
                    size,
                    _selectedSize,
                    () => _selectGoodsVariant(
                      size,
                      _selectedColor!,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // 색상 태그
          const Text(
            'color',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: uniqueColors
                .map(
                  (color) => _buildOptionTag(
                    color,
                    _selectedColor,
                    () => _selectGoodsVariant(
                      _selectedSize!,
                      color,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // 재고 현황 그래프
          const Text(
            '재고 현황',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _StockPainter(
                    stockRatio: stockRatio,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentStock/$maxStock',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(stockRatio * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택 옵션: ${_selectedSize} / ${_selectedColor}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('현재 재고량: $currentStock개'),
                    Text('총 판매량: 0개 (더미)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 옵션 태그 위젯 (DB 연동 및 선택 상태 반영)
  Widget _buildOptionTag(
    String text,
    String? selectedValue,
    VoidCallback onTap,
  ) {
    final isSelected = text == selectedValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Colors.black
                : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.grey.shade700,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 5. 발주하기 스냅 다이얼로그 (BottomSheet)
  void _showOrderBottomSheet() {
    // 현재 선택된 옵션의 정보를 초기값으로 설정
    final Goods? currentVariant = _selectedVariant;
    if (currentVariant == null) return;

    // 발주 수량 컨트롤러
    final TextEditingController quantityController =
        TextEditingController(text: '1');
    int orderQuantity = 1;

    Get.bottomSheet(
      StatefulBuilder(
        builder:
            (
              BuildContext context,
              StateSetter setModalState,
            ) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // 제품 정보
                    const Center(
                      child: Text(
                        '발주 신청',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Image.asset(
                          (currentVariant.mainimage ??
                                  'images/default.png')
                              .toString(),
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) => const Icon(
                                Icons.inventory_2_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentVariant.gname,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                '제품코드 : ${currentVariant.gseq.toString()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    // 사이즈, 색상 및 수량
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        // 선택 옵션 표시
                        _buildModalTag(
                          currentVariant.gsize,
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        _buildModalTag(
                          currentVariant.gcolor,
                          onTap: () {},
                        ),
                        const Spacer(),

                        // 수량 입력 필드 (Counter)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade400,
                            ),
                            borderRadius:
                                BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              // 수량 감소
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    if (orderQuantity > 1) {
                                      orderQuantity--;
                                      quantityController
                                              .text =
                                          orderQuantity
                                              .toString();
                                    }
                                  });
                                },
                              ),
                              // 수량 입력 필드
                              SizedBox(
                                width: 30,
                                child: TextField(
                                  controller:
                                      quantityController,
                                  textAlign:
                                      TextAlign.center,
                                  keyboardType:
                                      TextInputType.number,
                                  decoration:
                                      const InputDecoration(
                                        border: InputBorder
                                            .none,
                                        contentPadding:
                                            EdgeInsets.zero,
                                      ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      orderQuantity =
                                          int.tryParse(
                                            value,
                                          ) ??
                                          1;
                                      if (orderQuantity <
                                          1) {
                                        orderQuantity = 1;
                                        quantityController
                                                .text =
                                            '1';
                                      }
                                    });
                                  },
                                ),
                              ),
                              // 수량 증가
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    orderQuantity++;
                                    quantityController
                                            .text =
                                        orderQuantity
                                            .toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 취소 및 발주 신청하기 버튼
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // DB 재고 업데이트 로직 호출
                            _processOrder(
                              currentVariant.gseq!,
                              orderQuantity,
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '발주 신청하기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
      ),
      isScrollControlled: true,
    );
  }

  // 모달 내 사이즈/색상 태그 (옵션 표시용)
  Widget _buildModalTag(
    String text, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 재고 비율을 시각화하는 커스텀 페인터 (원형 그래프)는 변경 없이 유지합니다.
class _StockPainter extends CustomPainter {
  final double stockRatio;

  _StockPainter({required this.stockRatio});

  @override
  void paint(Canvas canvas, Size size) {
    // ... (기존 _StockPainter 코드 유지)
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 배경 (전체 원)
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    // 데이터 부분 (주황색)
    final dataPaint = Paint()
      ..color = Colors.orange.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // 전체 원 그리기
    canvas.drawCircle(center, radius - 5, backgroundPaint);

    // 데이터 부분 호(Arc) 그리기
    double sweepAngle =
        2 *
        3.1415926535 *
        stockRatio.clamp(0.0, 1.0); // 2 * PI * 비율 (범위 제한)

    // 호는 12시 방향(시작 각도 -PI/2)부터 그리기 시작
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -3.1415926535 /
          2, // Start angle (12 o'clock position)
      sweepAngle,
      false,
      dataPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StockPainter oldDelegate) {
    return oldDelegate.stockRatio != stockRatio;
  }
}
