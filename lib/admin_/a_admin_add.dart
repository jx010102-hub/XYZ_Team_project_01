import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

class AdminAdd extends StatefulWidget {
  const AdminAdd({super.key});

  @override
  State<AdminAdd> createState() => _AdminAddState();
}

class _AdminAddState extends State<AdminAdd> {
  // Controllers
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _engNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Image bytes (DB 저장용)
  Uint8List? _mainImageBytes;
  Uint8List? _topImageBytes;
  Uint8List? _backImageBytes;
  Uint8List? _sideImageBytes;

  final ImagePicker _picker = ImagePicker();

  // 단위(간격) 선택: 5mm / 10mm
  final List<int> _units = const [5, 10];
  int _selectedUnit = 5;

  // 최소/최대 선택값 (단위에 따라 옵션 목록이 달라짐)
  int _minSize = 250;
  int _maxSize = 280;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 초기값은 위 변수에 이미 지정 (250~280, 5mm)
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    _nameController.dispose();
    _engNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // ✅ 사이즈 리스트 생성 규칙
  //  - unit=5: 5단위로 쭉
  //  - unit=10: 10단위로 쭉 가되, 마지막이 max가 아니면 max를 추가(= 마지막만 5 보정 효과)
  //    예) 245~270, unit=10 => 245,255,265,270 (마지막 max 포함)
  // ------------------------------------------------------------
  List<int> _generateSizeList({
    required int minSize,
    required int maxSize,
    required int unit,
  }) {
    final List<int> sizes = [];
    int current = minSize;

    while (current < maxSize) {
      sizes.add(current);
      current += unit;
    }

    if (sizes.isEmpty || sizes.last != maxSize) {
      sizes.add(maxSize);
    }

    // 혹시 중복 생기면 제거
    return sizes.toSet().toList()..sort();
  }

  // ------------------------------------------------------------
  // ✅ 드롭다운에 보여줄 사이즈 후보 리스트
  //  - 단위가 5면 5단위 전체
  //  - 단위가 10이면 5단위 전체에서 선택은 하되,
  //    실제 저장 옵션은 generateSizeList에서 규칙 적용
  //    (최소/최대는 5단위로 자유롭게 가능해야 "245~270" 케이스가 가능함)
  // ------------------------------------------------------------
  List<int> get _dropdownSizeCandidates {
    // 220~300을 5단위로 제공 (자연스러운 신발 사이즈 범위)
    return List<int>.generate(((300 - 220) ~/ 5) + 1, (i) => 220 + (i * 5));
  }

  // ---------------------------
  // Image Picker
  // ---------------------------
  Future<void> _pickImage(String type) async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final Uint8List bytes = await picked.readAsBytes();

      if (!mounted) return;
      setState(() {
        switch (type) {
          case 'Main Image':
            _mainImageBytes = bytes;
            break;
          case 'Top Image':
            _topImageBytes = bytes;
            break;
          case 'Back Image':
            _backImageBytes = bytes;
            break;
          case 'Side Image':
            _sideImageBytes = bytes;
            break;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류: $e')),
      );
    }
  }

  // ---------------------------
  // Register Goods
  // ---------------------------
  Future<void> _registerGoods() async {
    if (_isSaving) return;

    final String manufacturer = _manufacturerController.text.trim();
    final String gname = _nameController.text.trim();
    final String gengname = _engNameController.text.trim();
    final String priceText = _priceController.text.trim();

    if (manufacturer.isEmpty || gname.isEmpty || gengname.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제조사/상품명/영문명/가격은 필수 입력임')),
      );
      return;
    }

    final double? price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가격은 숫자로 입력해야 함')),
      );
      return;
    }

    if (_minSize > _maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 사이즈가 최대 사이즈보다 클 수 없음')),
      );
      return;
    }

    // 이미지 4개 필수
    if (_mainImageBytes == null || _topImageBytes == null || _backImageBytes == null || _sideImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 4개를 모두 등록해줘')),
      );
      return;
    }

    // ✅ 실제 저장할 사이즈 옵션 문자열 생성
    final List<int> sizes = _generateSizeList(
      minSize: _minSize,
      maxSize: _maxSize,
      unit: _selectedUnit,
    );
    final String sizeOptionsString = sizes.join(', '); // 예: "250, 255, 260 ..."

    // 카테고리/색상 UI가 없으니 일단 기본값 처리
    const String defaultCategory = '기타';
    const String defaultColor = '기본';

    final Goods newGoods = Goods(
      gseq: null,
      gsumamount: 50,
      gname: gname,
      gengname: gengname,
      gsize: sizeOptionsString, // ✅ 옵션 리스트 형태로 저장
      gcolor: defaultColor,
      gcategory: defaultCategory,

      // ✅ 추가 컬럼
      manufacturer: manufacturer,
      price: price,

      // ✅ 이미지 Blob
      mainimage: _mainImageBytes,
      topimage: _topImageBytes,
      backimage: _backImageBytes,
      sideimage: _sideImageBytes,
    );

    setState(() => _isSaving = true);

    try {
      final db = GoodsDatabase();
      final int result = await db.insertGoods(newGoods);

      if (!mounted) return;

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 상품 등록 완료')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ 등록 실패(중복이거나 DB insert 실패)')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ DB 저장 중 오류: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final sizesPreview = _generateSizeList(minSize: _minSize, maxSize: _maxSize, unit: _selectedUnit);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '상품 등록',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) 이미지
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildImageUploadSection(),
            ),

            // 2) 기본 정보
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildInfoInputSection(),
            ),

            // 3) 사이즈 범위
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildSizeRangeSection(),
            ),

            // ✅ 생성될 옵션 미리보기 (UX 좋아짐)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '생성될 사이즈 옵션: ${sizesPreview.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _registerGoods,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          '등록하기',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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

  // 1) 이미지 등록 섹션
  Widget _buildImageUploadSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _imageCard('Main Image', _mainImageBytes),
            _imageCard('Top Image', _topImageBytes),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _imageCard('Back Image', _backImageBytes),
              _imageCard('Side Image', _sideImageBytes),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageCard(String title, Uint8List? bytes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: GestureDetector(
            onTap: () => _pickImage(title),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: bytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50, color: Colors.grey),
                        Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Text('이미지 등록', style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(bytes, fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // 2) 상품 정보 입력 섹션
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
          hint: '상품 가격을 입력해 주세요. (예: 150000)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  // 3) 사이즈 범위 섹션
  Widget _buildSizeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('사이즈 범위', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDropdownInt(
                  label: '최소',
                  value: _minSize,
                  items: _dropdownSizeCandidates,
                  onChanged: (int? v) {
                    if (v == null) return;
                    setState(() {
                      _minSize = v;
                      if (_minSize > _maxSize) _maxSize = _minSize;
                    });
                  },
                ),
              ),
              Expanded(
                child: _buildDropdownInt(
                  label: '최대',
                  value: _maxSize,
                  items: _dropdownSizeCandidates,
                  onChanged: (int? v) {
                    if (v == null) return;
                    setState(() {
                      _maxSize = v;
                      if (_maxSize < _minSize) _minSize = _maxSize;
                    });
                  },
                ),
              ),
              Expanded(
                child: _buildDropdownInt(
                  label: '간격',
                  value: _selectedUnit,
                  items: _units,
                  onChanged: (int? v) {
                    if (v == null) return;
                    setState(() => _selectedUnit = v);
                  },
                  suffixText: 'mm',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInt({
    required String label,
    required int value,
    required List<int> items,
    required Function(int?) onChanged,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: onChanged,
                items: items.map((v) {
                  final text = suffixText == null ? '$v' : '$v$suffixText';
                  return DropdownMenuItem<int>(
                    value: v,
                    child: Text(text),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
