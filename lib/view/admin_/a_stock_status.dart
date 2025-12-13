import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

import 'package:xyz_project_01/model/supply_order.dart';
import 'package:xyz_project_01/vm/database/supply_order_database.dart';

// 재고 현황 페이지
class AStockStatus extends StatefulWidget {
  const AStockStatus({super.key});

  @override
  State<AStockStatus> createState() => _AStockStatusState();
}

class _AStockStatusState extends State<AStockStatus> {
  final GoodsDatabase _goodsDatabase = GoodsDatabase();
  final SupplyOrderDatabase _orderDB = SupplyOrderDatabase();

  int _selectedTab = 1;

  String? _selectedMonth = 'Sep';
  String? _selectedYear = '2025';

  // ✅ 제조사 선택값
  String? _selectedManufacturer;
  String? _selectedProductName;

  final TextEditingController _productCodeController = TextEditingController();

  List<Goods> _representativeGoodsList = [];
  Goods? _selectedGoods;
  List<Goods> _goodsOptions = [];
  String? _selectedSize;
  String? _selectedColor;
  Goods? _selectedVariant;

  final List<String> _months = const [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  final List<String> _years = const ['2023', '2024', '2025'];

  // ✅ 더미 제조사 리스트 유지
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

  // -----------------------
  // DB
  // -----------------------
  Future<void> _fetchRepresentativeGoods() async {
    final goodsList = await _goodsDatabase.queryRepresentativeGoods();
    if (!mounted) return;

    setState(() {
      _representativeGoodsList = goodsList;

      if (goodsList.isNotEmpty) {
        _selectedProductName = goodsList.first.gname;

        // ✅ 기본 제조사 세팅(값은 잡되, 드롭다운 items에 없으면 null 처리되게 build에서 처리함)
        _selectedManufacturer = goodsList.first.manufacturer.trim().isNotEmpty
            ? goodsList.first.manufacturer.trim()
            : (_manufacturers.isNotEmpty ? _manufacturers.first : null);

        _fetchGoodsOptions(goodsList.first.gname);
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
        _productCodeController.text = (_selectedGoods!.gseq ?? '').toString();

        // ✅ 여기서도 제조사 최신 반영 (비어있으면 기존 선택 유지)
        final dbManu = options.first.manufacturer.trim();
        if (dbManu.isNotEmpty) {
          _selectedManufacturer = dbManu;
        }

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

  Future<void> _selectGoodsVariant(String size, String color) async {
    if (_selectedProductName == null) return;

    final variant = await _goodsDatabase.getGoodsVariant(
      gname: _selectedProductName!,
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

  // ✅ 발주 요청 (supply_order 테이블로 저장)
  Future<void> _processOrder(int gseq, int quantity) async {
    final v = _selectedVariant;
    if (v == null) return;

    // ✅ [핵심 수정 1] 드롭다운 선택 제조사를 우선 사용, 없으면 variant 제조사 사용
    final String manufacturer =
        (_selectedManufacturer?.trim().isNotEmpty == true)
            ? _selectedManufacturer!.trim()
            : v.manufacturer.trim();

    if (manufacturer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제조사를 선택해주세요')),
      );
      return;
    }

    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final order = SupplyOrder(
      manufacturer: manufacturer,
      requester: '',
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result > 0 ? '발주 요청 저장 완료' : '발주 요청 저장 실패')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DB insert 오류: $e')),
      );
      rethrow;
    }
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
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

            if (_selectedGoods != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStockDetailCard(_selectedGoods!),
              ),

            if (_selectedVariant != null) _buildStockInfoSection(),

            if (_selectedGoods == null && _selectedTab == 1)
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
                height: 50,
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
  }

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

          Row(
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
                  // ✅ [핵심 수정 2] items에 없는 제조사는 null 처리 (드롭다운 꼬임 방지)
                  value: (_selectedManufacturer != null && _manufacturers.contains(_selectedManufacturer))
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
          // ✅ [핵심 수정 3] initialValue → value 로 변경 (상태 변경 UI 반영 안정화)
          value: _selectedProductName,
          items: productNames.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedProductName = newValue);
              _fetchGoodsOptions(newValue);
            }
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
    required Function(String?) onChanged,
  }) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: DropdownButtonFormField<String>(
          // ✅ initialValue → value 로 변경
          value: value,
          items: items.map((String item) {
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

  // ✅ 카드에서 manufacturer / price 확인 가능하도록 추가
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
          const SizedBox(height: 8),

          Row(
            children: [
              _goodsThumb(goods.mainimage, width: 60, height: 60),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goods.gname,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      goods.gengname,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '제조사 : ${goods.manufacturer}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      '가격 : $priceText원',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
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
      child: Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildStockInfoSection() {
    final uniqueSizes = _goodsOptions.map((g) => g.gsize).toSet().toList();
    final uniqueColors = _goodsOptions.map((g) => g.gcolor).toSet().toList();

    final int currentStock = _selectedVariant?.gsumamount ?? 0;
    const int maxStock = 100;
    final double stockRatio = currentStock / maxStock;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: uniqueSizes.map((size) {
              return _buildOptionTag(
                size,
                _selectedSize,
                () => _selectGoodsVariant(size, _selectedColor!),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          const Text('color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: uniqueColors.map((color) {
              return _buildOptionTag(
                color,
                _selectedColor,
                () => _selectGoodsVariant(_selectedSize!, color),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          const Text('재고 현황', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
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
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택 옵션: $_selectedSize / $_selectedColor',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('현재 재고량: $currentStock개'),
                    const Text('총 판매량: 0개 (더미)'),
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

  Widget _buildOptionTag(String text, String? selectedValue, VoidCallback onTap) {
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
        builder: (BuildContext context, StateSetter setModalState) {
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
                    const SizedBox(width: 10),

                    Expanded(
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
                          const SizedBox(height: 4),
                          Text(
                            // ✅ 바텀시트 표시도 “선택된 제조사”가 있으면 그걸 보여주는 게 자연스럽긴 함
                            '제조사 : ${(_selectedManufacturer?.trim().isNotEmpty == true) ? _selectedManufacturer : currentVariant.manufacturer}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildModalTag(currentVariant.gsize, onTap: () {}),
                    const SizedBox(width: 10),
                    _buildModalTag(currentVariant.gcolor, onTap: () {}),
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

                const SizedBox(height: 30),

                Row(
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await _processOrder(currentVariant.gseq!, orderQuantity);
                          Get.back();
                          Get.snackbar('완료', '발주 요청 저장 완료', backgroundColor: Colors.black, colorText: Colors.white);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('발주 처리 중 오류: $e')),
                          );
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

  Widget _buildModalTag(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// 원형 그래프 페인터
class _StockPainter extends CustomPainter {
  final double stockRatio;
  _StockPainter({required this.stockRatio});

  @override
  void paint(Canvas canvas, Size size) {
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

    final sweepAngle = 2 * 3.1415926535 * stockRatio.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -3.1415926535 / 2,
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
