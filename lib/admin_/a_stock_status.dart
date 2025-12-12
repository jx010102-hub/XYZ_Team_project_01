import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 재고 현황 페이지
class AStockStatus extends StatefulWidget {
  const AStockStatus({super.key});

  @override
  State<AStockStatus> createState() => _AStockStatusState();
}

class _AStockStatusState extends State<AStockStatus> {
  // 탭 상태: 0 = 일자별, 1 = 제품별
  int _selectedTab = 0;

  // 드롭다운 및 텍스트 필드 상태
  String? _selectedMonth = 'Sep';
  String? _selectedYear = '2025';
  String? _selectedManufacturer = 'XYZ';
  String? _selectedProductName = '나이키 매직포스';
  final TextEditingController _productCodeController =
      TextEditingController(text: 's14235346');

  // --- 더미 데이터 (디자인에 맞춘 예시) ---
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
  ];
  final List<String> _productNames = [
    '나이키 매직포스',
    '파워레인저',
    '에어맥스',
  ];
  final List<String> _units = [
    '220',
    '230',
    '240',
    '250',
    '260',
    '270',
  ];
  final List<String> _colors = ['white', 'black', 'gray'];

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStockDetailCard(),
            ),

            // 4. 재고 현황 상세 정보 (사이즈, 색상, 그래프)
            _buildStockInfoSection(),

            // 5. 발주하기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showOrderBottomSheet,
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
              // 일자별 탭 버튼
              _buildTabButton(text: '일자별 현황', index: 0),
              const SizedBox(width: 10),
              // 제품별 탭 버튼
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
                _buildDropdown(
                  label: '제품명',
                  value: _selectedProductName,
                  items: _productNames,
                  onChanged: (val) => setState(
                    () => _selectedProductName = val,
                  ),
                ),
              ],
              // 나머지 공간 채우기 (Dropdown이 2개일 때 레이아웃 정렬을 위해)
              const Spacer(),
            ],
          ),
        ],
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

  // 드롭다운 위젯
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
    );
  }

  // 3. 재고 상세 현황 카드 (제품 정보)
  Widget _buildStockDetailCard() {
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
            '제품코드 : ${_productCodeController.text}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Image.asset(
                'images/main1.png', // 실제 이미지 경로로 변경 필요
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '나이키 매직포스 파워레인저 화이트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Nike Magic Force Power',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Rangers White',
                    style: TextStyle(
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
            children: _units
                .map(
                  (unit) =>
                      _buildTag(unit, Colors.grey[300]!),
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
            children: _colors
                .map(
                  (color) =>
                      _buildTag(color, Colors.grey[300]!),
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
              // 그래프 영역 (임시 구현)
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _StockPainter(
                    stockRatio: 0.6,
                  ), // 60% 재고율 예시
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          '60/100',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '60%',
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
              // 다른 정보가 들어갈 수 있는 공간
              const Expanded(child: Text('총 재고 현황 정보')),
            ],
          ),
        ],
      ),
    );
  }

  // 태그 위젯 (사이즈/색상)
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade400,
          width: text == '220' || text == 'white' ? 2 : 1,
        ), // 선택된 태그 강조
      ),
      child: Text(
        text,
        style: TextStyle(
          color: text == '220' || text == 'white'
              ? Colors.black
              : Colors.grey.shade700,
        ),
      ),
    );
  }

  // 5. 발주하기 스냅 다이얼로그 (BottomSheet)
  void _showOrderBottomSheet() {
    // 발주 수량 컨트롤러
    final TextEditingController quantityController =
        TextEditingController(text: '1');
    String selectedSize = '220'; // 선택된 사이즈 초기값
    String selectedColor = 'white'; // 선택된 색상 초기값

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
                          'images/main1.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ), // 이미지 경로 변경 필요
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '나이키 매직포스 파워레인저 화이트',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                '제품코드 : s14235346',
                                style: TextStyle(
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

                    // 사이즈 및 색상 선택
                    Row(
                      children: [
                        // 사이즈 선택 드롭다운 (현재는 텍스트로 대체)
                        _buildModalTag(
                          selectedSize,
                          onTap: () => setModalState(
                            () => selectedSize = '220',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 색상 선택 드롭다운 (현재는 텍스트로 대체)
                        _buildModalTag(
                          selectedColor,
                          onTap: () => setModalState(
                            () => selectedColor = 'white',
                          ),
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
                                    int current =
                                        int.tryParse(
                                          quantityController
                                              .text,
                                        ) ??
                                        1;
                                    if (current > 1) {
                                      quantityController
                                              .text =
                                          (current - 1)
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
                                  onChanged: (value) =>
                                      setModalState(
                                        () {},
                                      ), // 상태 업데이트
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
                                    int current =
                                        int.tryParse(
                                          quantityController
                                              .text,
                                        ) ??
                                        0;
                                    quantityController
                                            .text =
                                        (current + 1)
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
                            // 실제 발주 신청 로직 호출
                            Get.back();
                            Get.snackbar(
                              '성공',
                              '$selectedSize 사이즈, $selectedColor 색상으로 ${quantityController.text}개 발주 신청 완료',
                            );
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
      isScrollControlled:
          true, // 키보드가 올라올 때 다이얼로그가 밀려 올라가도록 설정
    );
  }

  // 모달 내 사이즈/색상 태그 (임시)
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
          border: Border.all(
            color: Colors.black,
            width: 2,
          ), // 항상 선택된 것처럼 강조
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

// 재고 비율을 시각화하는 커스텀 페인터 (원형 그래프)
class _StockPainter extends CustomPainter {
  final double stockRatio; // 0.0 ~ 1.0

  _StockPainter({required this.stockRatio});

  @override
  void paint(Canvas canvas, Size size) {
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
        2 * 3.1415926535 * stockRatio; // 2 * PI * 비율

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
