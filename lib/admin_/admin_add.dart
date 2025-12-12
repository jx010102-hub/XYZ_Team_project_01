import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatter 사용을 위해 추가

class AdminAdd extends StatefulWidget {
  const AdminAdd({super.key});

  @override
  State<AdminAdd> createState() => _AdminAddState();
}

class _AdminAddState extends State<AdminAdd> {
  // 텍스트 필드 컨트롤러
  final TextEditingController _manufacturerController =
      TextEditingController();
  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _engNameController =
      TextEditingController();
  final TextEditingController _priceController =
      TextEditingController();

  // 드롭다운 메뉴 항목 (예시 데이터)
  // 실제로는 DB에서 불러오거나 고정된 목록을 사용해야 합니다.
  final List<String> _sizes = [
    '220',
    '225',
    '230',
    '235',
    '240',
    '280',
    '285',
    '290',
  ];
  final List<String> _units = ['5mm', '10mm'];

  String? _minSize;
  String? _maxSize;
  String? _rangeUnit;

  // 더미 이미지 등록 함수 (실제로는 Image Picker 로직이 들어가야 함)
  void _pickImage(String type) {
    // 여기에 실제 이미지 등록 로직 (Image Picker)이 들어갑니다.
    print('$type 이미지 등록 버튼 클릭됨');
  }

  // 상품 등록 버튼 클릭 시
  void _registerGoods() {
    // 상품 등록 로직
    print("--- 상품 등록 시도 ---");
    print("제조사: ${_manufacturerController.text}");
    print("상품명: ${_nameController.text}");
    print("가격: ${_priceController.text}");
    print(
      "최소 사이즈: $_minSize, 최대 사이즈: $_maxSize, 단위: $_rangeUnit",
    );
    // 여기에 DB INSERT 로직을 호출해야 합니다.
  }

  @override
  void initState() {
    super.initState();
    // 초기 드롭다운 값 설정
    _minSize = _sizes.first;
    _maxSize = _sizes.last;
    _rangeUnit = _units.first;
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    _nameController.dispose();
    _engNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // '상품 등록' 제목 추가
        title: const Text(
          '상품 등록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pop(), // 뒤로 가기
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 등록 섹션
            _buildImageUploadSection(),
            const SizedBox(height: 30),

            // 2. 상품 정보 입력 섹션 (제조사, 상품명, 영문명, 가격)
            _buildInfoInputSection(),
            const SizedBox(height: 20),

            // 3. 사이즈 범위 설정 섹션
            _buildSizeRangeSection(),
            const SizedBox(height: 50),

            // 4. 등록 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerGoods,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 배경색 검정
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '등록하기',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 위젯 분리 함수 ---

  // 1. 이미지 등록 섹션
  Widget _buildImageUploadSection() {
    // 이미지 4개를 2x2 그리드로 배치
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _imageCard('Main Image'),
            _imageCard('Top Image'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _imageCard('Back Image'),
            _imageCard('Side Image'),
          ],
        ),
      ],
    );
  }

  // 이미지 등록 카드 위젯
  Widget _imageCard(String title) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(title),
          child: Container(
            width: 150, // 디자인에 맞춰 너비 설정
            height: 150, // 디자인에 맞춰 높이 설정
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 5),
                Text(
                  '이미지 등록',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. 상품 정보 입력 섹션
  Widget _buildInfoInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _manufacturerController,
          label: '제조사 이름',
          hint: '제조사 이름을 입력해 주세요.',
        ),
        _buildTextField(
          controller: _nameController,
          label: '상품 이름',
          hint: '상품 이름을 입력해 주세요.',
        ),
        _buildTextField(
          controller: _engNameController,
          label: '상품 영문 이름',
          hint: '상품 이름을 영어로 입력해 주세요.',
        ),
        _buildTextField(
          controller: _priceController,
          label: '상품 가격',
          hint: '상품 가격을 입력해 주세요.',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter
                .digitsOnly, // 숫자만 입력 가능하도록
          ],
        ),
      ],
    );
  }

  // 텍스트 필드 공통 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none, // 밑줄 제거
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. 사이즈 범위 설정 섹션
  Widget _buildSizeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사이즈 범위',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Divider(),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 최소 사이즈 드롭다운
            _buildDropdown(
              label: '최소 사이즈',
              value: _minSize,
              items: _sizes,
              onChanged: (String? newValue) {
                setState(() {
                  _minSize = newValue;
                });
              },
            ),

            // 최대 사이즈 드롭다운
            _buildDropdown(
              label: '최대 사이즈',
              value: _maxSize,
              items: _sizes,
              onChanged: (String? newValue) {
                setState(() {
                  _maxSize = newValue;
                });
              },
            ),

            // 범위 단위 드롭다운
            _buildDropdown(
              label: '범위 단위',
              value: _rangeUnit,
              items: _units,
              onChanged: (String? newValue) {
                setState(() {
                  _rangeUnit = newValue;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // 드롭다운 위젯
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: onChanged,
                  items: items
                      .map<DropdownMenuItem<String>>((
                        String item,
                      ) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
