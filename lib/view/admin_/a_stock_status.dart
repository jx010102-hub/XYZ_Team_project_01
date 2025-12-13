import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

import 'package:xyz_project_01/model/supply_order.dart';
import 'package:xyz_project_01/vm/database/supply_order_database.dart';

class AStockStatus extends StatefulWidget {
  const AStockStatus({super.key});

  @override
  State<AStockStatus> createState() => _AStockStatusState();
}

class _AStockStatusState extends State<AStockStatus> {
  // Property
  final GoodsDatabase _goodsDatabase = GoodsDatabase();
  final SupplyOrderDatabase _orderDB = SupplyOrderDatabase();

  int _selectedTab = 1;

  String? _selectedMonth = 'Sep';
  String? _selectedYear = '2025';

  String? _selectedManufacturer;
  String? _selectedProductName;

  final TextEditingController _productCodeController = TextEditingController();

  final Message msg = const Message();

  List<Goods> _representativeGoodsList = [];
  List<Goods> _goodsOptions = [];

  Goods? _selectedGoods;
  String? _selectedSize;
  String? _selectedColor;
  Goods? _selectedVariant;

  final List<String> _months = const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final List<String> _years = const ['2023', '2024', '2025'];

  // 더미 제조사 리스트(기존 유지)
  final List<String> _manufacturers = const ['나이키', '아디다스', 'XYZ'];

  @override
  void initState() {
    super.initState();
    _fetchRepresentativeGoods();
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
  }

  void _resetVariantSelection() {
    _selectedSize = null;
    _selectedColor = null;
    _selectedVariant = null;
  }


  // DB
  Future<void> _fetchRepresentativeGoods() async {
    final goodsList = await _goodsDatabase.queryRepresentativeGoods();
    if (!mounted) return;

    setState(() {
      _representativeGoodsList = goodsList;

      if (goodsList.isNotEmpty) {
        _selectedProductName = goodsList.first.gname;

        final dbManu = goodsList.first.manufacturer.trim();
        _selectedManufacturer = dbManu.isNotEmpty
            ? dbManu
            : (_manufacturers.isNotEmpty ? _manufacturers.first : null);

        _fetchGoodsOptions(goodsList.first.gname);
      } else {
        _selectedProductName = null;
        _selectedManufacturer = null;
        _goodsOptions = [];
        _selectedGoods = null;
        _productCodeController.text = '';
        _resetVariantSelection();
      }
    });
  }

  Future<void> _fetchGoodsOptions(String gname) async {
    if (gname.isEmpty) return;

    final options = await _goodsDatabase.getGoodsByName(gname);
    if (!mounted) return;

    setState(() {
      _goodsOptions = options;

      if (options.isNotEmpty) {
        _selectedGoods = options.first;

        final gseq = _selectedGoods!.gseq;
        _productCodeController.text = (gseq ?? '').toString();

        // 제조사 최신 반영(비어있으면 기존 선택 유지)
        final dbManu = options.first.manufacturer.trim();
        if (dbManu.isNotEmpty) {
          _selectedManufacturer = dbManu;
        }

        _selectedSize = options.first.gsize;
        _selectedColor = options.first.gcolor;
        _selectedVariant = options.first;
      } else {
        _selectedGoods = null;
        _productCodeController.text = '';
        _resetVariantSelection();
      }
    });
  }

  Future<void> _selectGoodsVariant(String size, String color) async {
    final name = _selectedProductName;
    if (name == null) return;

    final variant = await _goodsDatabase.getGoodsVariant(
      gname: name,
      gsize: size,
      gcolor: color,
    );

    if (!mounted) return;
    setState(() {
      _selectedSize = size;
      _selectedColor = color;
      _selectedVariant = variant;
    });
  }

  // 발주 요청
  Future<void> _processOrder(int gseq, int quantity) async {
    final v = _selectedVariant;
    if (v == null) return;

    final String manufacturer =
        (_selectedManufacturer?.trim().isNotEmpty == true)
            ? _selectedManufacturer!.trim()
            : v.manufacturer.trim();

    if (manufacturer.isEmpty) {
      msg.error('오류', '제조사를 선택해주세요');
      return;
    }

    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final order = SupplyOrder(
      manufacturer: manufacturer,
      requester: '', // 기존 유지(나중에 로그인 직원 정보 연결 가능)
      gseq: v.gseq!,
      gname: v.gname,
      gsize: v.gsize,
      gcolor: v.gcolor,
      qty: quantity,
      status: 0,
      reqdate: now,
    );

    try {
      final int result = await _orderDB.insertOrder(order);
      if (result > 0) {
        msg.success('완료', '발주 요청 저장 완료');
      } else {
        msg.error('실패', '발주 요청 저장 실패');
      }
    } catch (e) {
      msg.error('오류', '$e');
      rethrow;
    }
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    final Goods? goods = _selectedGoods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('재고 현황', style: TextStyle(fontWeight: FontWeight.bold)),
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
            _buildFilterAndSearchSection(),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildProductCodeSearch(),
            ),
            const Divider(height: 1, thickness: 1),
            if (goods != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStockDetailCard(goods),
              ),
            if (_selectedVariant != null) _buildStockInfoSection(),
            if (goods == null && _selectedTab == 1)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('조회할 상품을 선택해주세요.'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50, // ✅ 크기 고정은 유지
                child: ElevatedButton(
                  onPressed: _selectedVariant != null ? _showOrderBottomSheet : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    '발주하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // ---------------- Functions ----------------
  Widget _buildFilterAndSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTabButton(text: '일자별 현황', index: 0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _buildTabButton(text: '제품별 현황', index: 1),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedTab == 0) ...[
                  _buildDropdown(
                    label: '월별',
                    value: _selectedMonth,
                    items: _months,
                    onChanged: (val) => setState(() => _selectedMonth = val),
                  ),
                  _buildDropdown(
                    label: '연도',
                    value: _selectedYear,
                    items: _years,
                    onChanged: (val) => setState(() => _selectedYear = val),
                  ),
                ] else ...[
                  _buildDropdown(
                    label: '제조사',
                    value: (_selectedManufacturer != null &&
                            _manufacturers.contains(_selectedManufacturer))
                        ? _selectedManufacturer
                        : null,
                    items: _manufacturers,
                    onChanged: (val) => setState(() => _selectedManufacturer = val),
                  ),
                  _buildGoodsNameDropdown(),
                ],
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodsNameDropdown() {
    final productNames = _representativeGoodsList.map((g) => g.gname).toList();
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 7),
        child: DropdownButtonFormField<String>(
          value: _selectedProductName,
          items: productNames.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue == null) return;
            setState(() => _selectedProductName = newValue);
            _fetchGoodsOptions(newValue);
          },
          decoration: const InputDecoration(
            labelText: '제품명',
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({required String text, required int index}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedTab == index ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedTab == index ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCodeSearch() {
    return TextField(
      controller: _productCodeController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        hintText: '제품코드를 입력하세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      readOnly: true,
    );
  }

  Widget _buildStockDetailCard(Goods goods) {
    final priceText = NumberFormat('#,###').format(goods.price);

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
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _goodsThumb(goods.mainimage, width: 60, height: 60),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goods.gname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          goods.gengname,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '제조사 : ${goods.manufacturer}',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                        Text(
                          '가격 : $priceText원',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goodsThumb(Uint8List? bytes, {double width = 60, double height = 60}) {
    if (bytes == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(bytes, width: width, height: height, fit: BoxFit.cover),
    );
  }

  Widget _buildStockInfoSection() {
    final uniqueSizes = _goodsOptions.map((g) => g.gsize).toSet().toList();
    final uniqueColors = _goodsOptions.map((g) => g.gcolor).toSet().toList();

    final int currentStock = _selectedVariant?.gsumamount ?? 0;
    const int maxStock = 100;
    final double stockRatio = currentStock / maxStock;

    final selectedSize = _selectedSize;
    final selectedColor = _selectedColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8.0,
              children: uniqueSizes.map((size) {
                return _buildOptionTag(
                  text: size,
                  selectedValue: selectedSize,
                  onTap: () {
                    final c = selectedColor;
                    if (c == null) return;
                    _selectGoodsVariant(size, c);
                  },
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: const Text('color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8.0,
              children: uniqueColors.map((color) {
                return _buildOptionTag(
                  text: color,
                  selectedValue: selectedColor,
                  onTap: () {
                    final s = selectedSize;
                    if (s == null) return;
                    _selectGoodsVariant(s, color);
                  },
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: const Text('재고 현황', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100, // ✅ 크기 고정은 유지
                  child: CustomPaint(
                    painter: _StockPainter(stockRatio: stockRatio),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$currentStock/$maxStock',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택 옵션: $selectedSize / $selectedColor',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('현재 재고량: $currentStock개'),
                        const Text('총 판매량: 0개 (더미)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildOptionTag({
    required String text,
    required String? selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = text == selectedValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showOrderBottomSheet() {
    final Goods? currentVariant = _selectedVariant;
    if (currentVariant == null) return;

    final TextEditingController quantityController = TextEditingController(text: '1');
    int orderQuantity = 1;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '발주 신청',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    _goodsThumb(currentVariant.mainimage, width: 60, height: 60),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentVariant.gname,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '제품코드 : ${currentVariant.gseq.toString()}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '제조사 : ${(_selectedManufacturer?.trim().isNotEmpty == true) ? _selectedManufacturer : currentVariant.manufacturer}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildModalTag(currentVariant.gsize),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _buildModalTag(currentVariant.gcolor),
                    ),
                    const Spacer(),
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
                              setModalState(() {
                                if (orderQuantity > 1) {
                                  orderQuantity--;
                                  quantityController.text = orderQuantity.toString();
                                }
                              });
                            },
                          ),
                          SizedBox(
                            width: 30,
                            child: TextField(
                              controller: quantityController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  orderQuantity = int.tryParse(value) ?? 1;
                                  if (orderQuantity < 1) {
                                    orderQuantity = 1;
                                    quantityController.text = '1';
                                  }
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              setModalState(() {
                                orderQuantity++;
                                quantityController.text = orderQuantity.toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('취소', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await _processOrder(currentVariant.gseq!, orderQuantity);
                              Get.back();
                              msg.success('완료', '발주 요청 저장 완료');
                            } catch (e) {
                              msg.error('오류', '발주 처리 중 오류: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('발주 신청하기', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildModalTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _StockPainter extends CustomPainter {
  final double stockRatio;
  _StockPainter({required this.stockRatio});

  @override
  void paint(Canvas canvas, Size size) {
    const pi = 3.1415926535;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final dataPaint = Paint()
      ..color = Colors.orange.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 5, backgroundPaint);

    final sweepAngle = 2 * pi * stockRatio.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -pi / 2,
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
