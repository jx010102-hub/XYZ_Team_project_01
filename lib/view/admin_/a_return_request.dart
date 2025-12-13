import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AReturnRequest extends StatefulWidget {
  const AReturnRequest({super.key});

  @override
  State<AReturnRequest> createState() =>
      _AReturnRequestState();
}

class _AReturnRequestState extends State<AReturnRequest> {
  // --- 상태 변수 ---

  // 전체보기 드롭다운 메뉴 목록
  final List<String> _viewOptions = [
    '전체보기',
    '처리 대기',
    '처리 완료',
  ];
  String _selectedViewOption = '전체보기'; // 현재 선택된 옵션

  // 날짜 필터 유형: 0=오늘일자, 1=선택일자
  int _selectedDateType = 0;

  // 날짜 관련 드롭다운 상태
  String? _selectedMonth = 'Sep';
  String? _selectedYear = '2025';

  // 선택일자 버튼에 표시될 날짜
  String _selectedDate = '2025-12-09';

  // --- 더미 데이터 ---
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

  // 반품 요청 리스트 (더미)
  final List<Map<String, dynamic>> _returnItems = [
    {
      'id': 1,
      'date': '2025-12-09',
      'name': '나이키 매직포스 파워레인저 화이트',
      'engName': 'Nike Magic Force Power Rangers White',
      'checked': false,
    },
    {
      'id': 2,
      'date': '2025-12-09',
      'name': '나이키 매직포스 파워레인저 화이트',
      'engName': 'Nike Magic Force Power Rangers White',
      'checked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '반품 요청',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 필터 및 날짜 선택 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFilterSection(),
          ),
          const Divider(height: 1, thickness: 1),

          // 2. 반품 요청 목록
          Expanded(child: _buildReturnList()),

          // 3. 승인하기 버튼
          _buildApprovalButton(),
        ],
      ),
    );
  }

  // --- 위젯 구성 함수 ---

  // 1. 필터 섹션 (드롭다운, 날짜 버튼, 월/연도 드롭다운)
  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체보기 드롭다운
        _buildViewOptionDropdown(),
        const SizedBox(height: 10),

        // 날짜 선택 버튼 그룹 (오늘일자, 선택일자)
        _buildDateTypeButtons(),
        const SizedBox(height: 10),

        // 월/연도 드롭다운 및 요청 건수
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 월 드롭다운
            _buildDropdown(
              value: _selectedMonth,
              items: _months,
              onChanged: (val) =>
                  setState(() => _selectedMonth = val),
            ),
            // 연도 드롭다운
            _buildDropdown(
              value: _selectedYear,
              items: _years,
              onChanged: (val) =>
                  setState(() => _selectedYear = val),
            ),

            // 요청 건수 텍스트
            const Spacer(),
            Text(
              '${_returnItems.length}/2건', // 현재 건수 / 전체 건수 (더미)
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 전체보기 드롭다운
  Widget _buildViewOptionDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton<String>(
          value: _selectedViewOption,
          items: _viewOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedViewOption = newValue!;
            });
          },
        ),
      ),
    );
  }

  // 날짜 유형 선택 버튼 (오늘일자/선택일자)
  Widget _buildDateTypeButtons() {
    return Row(
      children: [
        // 오늘일자 버튼
        _buildDateToggleButton(
          text: '오늘일자',
          index: 0,
          onTap: () =>
              setState(() => _selectedDateType = 0),
        ),
        const SizedBox(width: 8),

        // 선택일자 버튼 (날짜 선택 다이얼로그 기능 포함)
        _buildDateToggleButton(
          text: _selectedDateType == 1
              ? '선택일자: $_selectedDate'
              : '선택일자',
          index: 1,
          onTap: () {
            setState(() => _selectedDateType = 1);
            if (_selectedDateType == 1) {
              _selectDate(context); // 선택일자 버튼을 누르면 달력 표시
            }
          },
        ),
      ],
    );
  }

  // 날짜 선택 다이얼로그 (캘린더)를 띄우는 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black, // 헤더 배경색
              onPrimary: Colors.white, // 헤더 텍스트 색상
              onSurface: Colors.black, // 일반 텍스트 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 버튼 텍스트 색상
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // 날짜 토글 버튼 위젯
  Widget _buildDateToggleButton({
    required String text,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedDateType == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 월/연도 드롭다운 위젯
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
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
            ),
          ),
        ),
      ),
    );
  }

  // 2. 반품 요청 목록
  Widget _buildReturnList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _returnItems.length,
      itemBuilder: (context, index) {
        final item = _returnItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildReturnItemCard(item),
        );
      },
    );
  }

  // 반품 요청 아이템 카드 위젯
  Widget _buildReturnItemCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 요청 일자 (상단에 텍스트로 추가)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '요청 일시: ${item['date']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    // 상품 이미지
                    Image.asset(
                      'images/main1.png', // 실제 이미지 경로로 변경 필요
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    // 상품 정보
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          item['engName'],
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
          ),

          // 체크박스
          Checkbox(
            value: item['checked'] as bool,
            onChanged: (bool? newValue) {
              setState(() {
                item['checked'] = newValue!;
              });
            },
            activeColor: Colors.black, // 체크 시 색상
          ),
        ],
      ),
    );
  }

  // 3. 승인하기 버튼
  Widget _buildApprovalButton() {
    // 체크된 항목이 있는지 확인
    final bool hasCheckedItems = _returnItems.any(
      (item) => item['checked'] == true,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: hasCheckedItems
              ? _approveReturns
              : null, // 체크된 항목이 있을 때만 활성화
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 5,
          ),
          child: const Text(
            '승인하기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // 반품 승인 처리 함수
  void _approveReturns() {
    final approvedItems = _returnItems
        .where((item) => item['checked'] == true)
        .toList();
    if (approvedItems.isNotEmpty) {
      // 실제 반품 승인 로직 (DB 업데이트 등) 호출
      Get.snackbar(
        '반품 승인',
        '${approvedItems.length}건의 반품 요청이 승인되었습니다.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // 승인 후 목록을 업데이트하거나 페이지를 새로고침하는 로직 추가
      // (여기서는 임시로 체크 상태만 해제)
      setState(() {
        for (var item in _returnItems) {
          item['checked'] = false;
        }
      });
    }
  }
}
