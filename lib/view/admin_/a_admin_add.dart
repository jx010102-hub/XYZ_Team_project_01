import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

enum GoodsImageType { main, top, back, side }

class AdminAdd extends StatefulWidget {
  const AdminAdd({super.key});

  @override
  State<AdminAdd> createState() => _AdminAddState();
}

class _AdminAddState extends State<AdminAdd> {
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _engNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Uint8List? _mainImageBytes;
  Uint8List? _topImageBytes;
  Uint8List? _backImageBytes;
  Uint8List? _sideImageBytes;

  final ImagePicker _picker = ImagePicker();
  final Message msg = const Message();

  final List<int> _units = const [5, 10];
  int _selectedUnit = 5;
  int _minSize = 250;
  int _maxSize = 280;

  bool _isSaving = false;

  @override
  void dispose() {
    _manufacturerController.dispose();
    _nameController.dispose();
    _engNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ---------------- 이미지 선택 ----------------
  Future<void> _pickImage(GoodsImageType type) async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        switch (type) {
          case GoodsImageType.main:
            _mainImageBytes = bytes;
            break;
          case GoodsImageType.top:
            _topImageBytes = bytes;
            break;
          case GoodsImageType.back:
            _backImageBytes = bytes;
            break;
          case GoodsImageType.side:
            _sideImageBytes = bytes;
            break;
        }
      });
    } catch (e) {
      msg.error('이미지 선택 중 오류', '$e');
    }
  }

  // ---------------- 상품 등록 ----------------
  Future<void> _registerGoods() async {
    if (_isSaving) return;

    final manufacturer = _manufacturerController.text.trim();
    final gname = _nameController.text.trim();
    final gengname = _engNameController.text.trim();
    final priceText = _priceController.text.trim();
    final double? price = double.tryParse(priceText);

    if (manufacturer.isEmpty || gname.isEmpty || gengname.isEmpty || priceText.isEmpty) {
      msg.error('입력 오류', '제조사/상품명/영문명/가격은 필수 입력임');
      return;
    }

    if (price == null) {
      msg.error('입력 오류', '가격은 숫자로 입력해야 함');
      return;
    }

    if (_minSize > _maxSize) {
      msg.error('입력 오류', '최소 사이즈가 최대 사이즈보다 클 수 없음');
      return;
    }

    if (_mainImageBytes == null ||
        _topImageBytes == null ||
        _backImageBytes == null ||
        _sideImageBytes == null) {
      msg.error('입력 오류', '이미지 4개를 모두 등록해줘');
      return;
    }

    final sizes = _buildSizeOptions(
      minSize: _minSize,
      maxSize: _maxSize,
      unit: _selectedUnit,
    );

    setState(() => _isSaving = true);

    try {
      final db = GoodsDatabase();
      int successCount = 0;

      for (final s in sizes) {
        final goodsRow = Goods(
          gseq: null,
          gsumamount: 50,
          gname: gname,
          gengname: gengname,

          // ✅ 여기 핵심: "250" 같은 단일 사이즈로 저장
          gsize: s.toString(),

          gcolor: '기본',      // 색상도 나중에 옵션이면 여기도 루프/선택값으로 확장
          gcategory: '기타',
          manufacturer: manufacturer,
          price: price,

          mainimage: _mainImageBytes,
          topimage: _topImageBytes,
          backimage: _backImageBytes,
          sideimage: _sideImageBytes,
        );

        final r = await db.insertGoods(goodsRow);
        if (r > 0) successCount++;
      }

      if (!mounted) return;

      if (successCount == sizes.length) {
        msg.success('완료', '상품 등록 완료 (사이즈 ${sizes.length}개 생성됨)');
        Navigator.pop(context);
      } else {
        msg.warning('부분 실패', '일부 사이즈만 등록됨 ($successCount / ${sizes.length})');
      }
    } catch (e) {
      msg.error('DB 오류', '저장 중 오류 발생: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    final previewSizes =
        _buildSizeOptions(minSize: _minSize, maxSize: _maxSize, unit: _selectedUnit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 등록', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildImageUploadSection(),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInfoInputSection(),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSizeRangeSection(),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '생성될 사이즈 옵션: ${previewSizes.join(', ')}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _registerGoods,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // ---------------- Functions ----------------
  List<int> _buildSizeOptions({
    required int minSize,
    required int maxSize,
    required int unit,
  }) {
    final sizes = <int>[];
    for (int v = minSize; v <= maxSize; v += unit) {
      sizes.add(v);
    }
    return sizes;
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _imageCard('Main Image', _mainImageBytes, () => _pickImage(GoodsImageType.main)),
              _imageCard('Top Image', _topImageBytes, () => _pickImage(GoodsImageType.top)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _imageCard('Back Image', _backImageBytes, () => _pickImage(GoodsImageType.back)),
            _imageCard('Side Image', _sideImageBytes, () => _pickImage(GoodsImageType.side)),
          ],
        ),
      ],
    );
  }

  Widget _imageCard(String title, Uint8List? bytes, VoidCallback onTap) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: bytes == null
                ? const Icon(Icons.image, size: 50, color: Colors.grey)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(bytes, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoInputSection() {
    return Column(
      children: [
        _buildTextField(_manufacturerController, '제조사 이름'),
        _buildTextField(_nameController, '상품 이름'),
        _buildTextField(_engNameController, '상품 영문 이름'),
        _buildTextField(
          _priceController,
          '상품 가격',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRangeSection() {
    final sizeCandidates =
        List<int>.generate(((300 - 220) ~/ 5) + 1, (i) => 220 + (i * 5));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('사이즈 범위', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        Row(
          children: [
            Expanded(child: _buildDropdownInt('최소', _minSize, sizeCandidates, (v) {
              if (v == null) return;
              setState(() {
                _minSize = v;
                if (_minSize > _maxSize) _maxSize = _minSize;
              });
            })),
            Expanded(child: _buildDropdownInt('최대', _maxSize, sizeCandidates, (v) {
              if (v == null) return;
              setState(() {
                _maxSize = v;
                if (_maxSize < _minSize) _minSize = _maxSize;
              });
            })),
            Expanded(child: _buildDropdownInt('간격', _selectedUnit, _units, (v) {
              if (v == null) return;
              setState(() => _selectedUnit = v);
            }, suffix: 'mm')),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownInt(
    String label,
    int value,
    List<int> items,
    ValueChanged<int?> onChanged, {
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          DropdownButton<int>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(suffix == null ? '$v' : '$v$suffix'),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
} // class