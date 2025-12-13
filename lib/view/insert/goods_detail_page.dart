// lib/insert/goods_detail_page.dart 파일 전체 내용

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/view/insert/goods_Info_Page.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/view/pay/paypage.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';
import 'dart:typed_data'; // Uint8List 사용

class GoodsDetailPage extends StatefulWidget {
  final Goods goods;
  final String userid;

  const GoodsDetailPage({super.key, required this.goods, required this.userid});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  // ⭐️⭐️⭐️ DB 로드 상태 변수 및 데이터 ⭐️⭐️⭐️
  bool _isLoadingOptions = true;
  int _currentImageIndex = 0;
  
  // 현재 상품과 동일한 GNAME을 가진 모든 옵션 리스트
  List<Goods> _allOptions = [];

  // 옵션 선택에 사용할 Set (중복 제거)
  Set<String> _availableSizes = {};
  Map<String, int> _availableColorMap = {}; // {'색상명': ColorHex}

  // ⭐️ 옵션 상태 관리 변수
  String? _selectedSize;
  String? _selectedColor;
  int _purchaseQuantity = 1;

  // ⭐️ 이미지 리스트 (DB 데이터로 채워짐)
  List<Uint8List> _displayImages = [];
  
  // ⭐️⭐️⭐️ initState: DB 데이터 로드 시작 ⭐️⭐️⭐️
  @override
  void initState() {
    super.initState();
    _loadOptionsData();
  }

  // ⭐️⭐️⭐️ DB에서 해당 상품의 모든 옵션 데이터를 로드하는 함수 ⭐️⭐️⭐️
  Future<void> _loadOptionsData() async {
    final goodsDB = GoodsDatabase();
    
    // 1. 같은 gname을 가진 모든 옵션(size, color 조합)을 DB에서 가져옴
    _allOptions = await goodsDB.getGoodsByName(widget.goods.gname);

    if (_allOptions.isNotEmpty) {
      // 2. 옵션 추출 및 이미지 리스트 구성
      final Set<String> sizes = {};
      final Map<String, int> colorMap = {};
      final List<Uint8List?> uniqueImages = [];
      
      // 대표 상품의 이미지들을 리스트에 추가 (null이 아닌 경우만)
      if (widget.goods.mainimage != null) uniqueImages.add(widget.goods.mainimage!);
      if (widget.goods.topimage != null) uniqueImages.add(widget.goods.topimage!);
      if (widget.goods.backimage != null) uniqueImages.add(widget.goods.backimage!);
      if (widget.goods.sideimage != null) uniqueImages.add(widget.goods.sideimage!);

      // 중복 이미지 제거 후 표시용 리스트에 할당
      _displayImages = uniqueImages.toSet().toList().cast<Uint8List>();
      
      // 옵션 추출
      for (var goods in _allOptions) {
        sizes.add(goods.gsize);
        
        // 색상은 임시로 해시코드 값을 부여하거나, 한글명을 사용
        // 여기서는 간단히 한글명만 사용하며, 색상값은 임시로 하드코딩합니다.
        // 실제로는 DB에 색상 Hex 코드가 있어야 합니다.
        if (!colorMap.containsKey(goods.gcolor)) {
            colorMap[goods.gcolor] = _getTempColorHex(goods.gcolor);
        }
      }
      
      // 3. 상태 업데이트
      setState(() {
        _availableSizes = sizes;
        _availableColorMap = colorMap;
        _isLoadingOptions = false;
        
        // 기본 옵션 설정 (첫 번째 항목)
        _selectedSize = _availableSizes.isNotEmpty ? _availableSizes.first : null;
        _selectedColor = _availableColorMap.isNotEmpty ? _availableColorMap.keys.first : null;
      });
      
      print("✅ [Detail] ${widget.goods.gname}의 옵션 데이터 로드 완료.");
      print("✅ [Detail] 사이즈 옵션 수: ${_availableSizes.length}, 색상 옵션 수: ${_availableColorMap.length}");

    } else {
       setState(() {
        _isLoadingOptions = false;
      });
      print("❌ [Detail] ${widget.goods.gname}에 해당하는 옵션 데이터가 DB에 없습니다.");
    }
  }
  
  // 임시 색상 맵핑 함수 (DB에 Hex 코드가 없을 경우)
  int _getTempColorHex(String colorName) {
    switch (colorName) {
      case '흰색': return 0xFFFFFFFF;
      case '검정색': return 0xFF000000;
      case '회색': return 0xFFCCCCCC;
      case '시그니쳐 색상': return 0xFF3F51B5; // 임의의 시그니처 색상
      default: return 0xFF808080; // 기본 회색
    }
  }

  // ⭐️⭐️⭐️ 빌드 함수 ⭐️⭐️⭐️
  @override
  Widget build(BuildContext context) {
    if (_isLoadingOptions) {
      return const Scaffold(
        appBar: null,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.home_outlined, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImageSection(), // DB 이미지로 변경
            _buildPriceAndNameSection(), // 가격 및 이름 섹션
            // TODO: 여기에 다른 상세 정보 섹션 추가 (옵션, 리뷰 등)
            const SizedBox(height: 100), // 바닥 여백 확보
          ],
        ),
      ),
      // 5. 하단 고정 구매 버튼 바
      bottomNavigationBar: _buildBottomPurchaseBar(context),
    );
  }

  // ⭐️⭐️⭐️ 1. DB 이미지/슬라이더 섹션 ⭐️⭐️⭐️
  Widget _buildProductImageSection() {
    return SizedBox(
      height: 400, // 이미지 영역 높이
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 실제 이미지 슬라이더 (PageView) - DB 데이터 사용
          PageView.builder(
            itemCount: _displayImages.length, // DB에서 추출된 이미지 수
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index; // 페이지 변경 시 인덱스 업데이트
              });
            },
            itemBuilder: (context, index) {
              return Image.memory(
                _displayImages[index], // DB에서 불러온 Uint8List
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
                // 이미지가 로드되지 않을 경우 대비
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              );
            },
          ),

          // 2. 좋아요/제품상세 버튼
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                // 좋아요 버튼
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: const Icon(Icons.thumb_up_alt_outlined, color: Colors.black),
                ),
                const SizedBox(width: 10),
                // 제품상세 > 버튼
                GestureDetector(
                  onTap: () {
                    // GoodsInfoPage로 이동 시 현재 Goods 객체를 넘겨 상세 정보 표시 가능
                    Get.to(GoodsInfoPage(goods: widget.goods)); 
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: const Text(
                      '제품상세 >',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 3. 페이지 인디케이터
          Positioned(
            bottom: 70,
            child: Row(
              children: List.generate(
                _displayImages.length, // 이미지 수에 맞게 인디케이터 조정
                (index) => _buildIndicator(index == _currentImageIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 가격 및 이름 섹션
  Widget _buildPriceAndNameSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그
          Row(
            children: [
              _buildTag('주간전체 1위'),
              const SizedBox(width: 8),
              _buildTag(
                'Top 100. ${widget.goods.gcategory}',
              ), 
            ],
          ),
          const SizedBox(height: 15),

          // ⭐️ 가격: 고정된 150,000원 사용
          const Text(
            "150,000원",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // 제품명 (한글)
          Text(
            widget.goods.gname,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),

          // 제품명 (영문)
          Text(
            widget.goods.gengname,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),

          // 별점 및 리뷰 수 (가상 데이터 유지)
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 5),
              const Text('4.0', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                ' (리뷰 2,000)',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 태그 위젯 (재사용)
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 인디케이터 위젯 (재사용)
  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }

  // 하단 고정 구매 버튼 바
  Widget _buildBottomPurchaseBar(BuildContext context) {
    return Container(
      height: 80, // 하단 바 높이
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // 1. 좋아요 버튼 (좌측)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 15),

          // 2. 구매하기 버튼 (우측)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // 구매하기 버튼 클릭 시 옵션 선택 바텀 시트 호출
                _showPurchaseOptions(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                '구매하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️⭐️⭐️ 옵션 선택 바텀 시트 (ShowModalBottomSheet) ⭐️⭐️⭐️
  void _showPurchaseOptions(BuildContext context) {
    
    // 옵션 데이터가 없을 경우 (로드 실패) 대비
    if (_availableSizes.isEmpty || _availableColorMap.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('상품 옵션 데이터를 로드하지 못했습니다.')),
        );
        return;
    }

    // 옵션 초기화 (선택이 없었다면 첫 번째 항목으로 설정)
    _selectedSize ??= _availableSizes.first;
    _selectedColor ??= _availableColorMap.keys.first;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // 바텀 시트 높이 설정
            double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            double sheetHeight = MediaQuery.of(context).size.height * 0.75 + bottomPadding;
            
            return Container(
              height: sheetHeight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닫기 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const Text(
                    '구매하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),

                  // 1. 선택된 상품 정보
                  _buildOptionProductInfo(widget.goods),

                  const Divider(height: 30),

                  // 2. 사이즈 옵션
                  const Text('사이즈', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // 스크롤 가능한 Wrap으로 변경
                  SizedBox(
                    height: 80, // 사이즈 옵션 스크롤 가능 높이
                    child: SingleChildScrollView(
                      child: _buildSizeOptions(setModalState),
                    ),
                  ),

                  const Divider(height: 30),

                  // 3. 색상 옵션
                  const Text('색깔', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildColorOptions(setModalState),

                  // 4. 수량 선택 섹션
                  if (_selectedSize != null && _selectedColor != null)
                    _buildQuantitySelector(setModalState),

                  const Spacer(),

                  // 5. 하단 버튼 바 (장바구니 담기, 바로 구매하기)
                  _buildOptionBottomBar(context),
                  
                  // 키보드에 따른 패딩
                  SizedBox(height: bottomPadding),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 바텀 시트 내부 - 상품 정보
  Widget _buildOptionProductInfo(Goods goods) {
    return Row(
      children: [
        // ⭐️⭐️⭐️ 상품 대표 이미지 (mainimage) 사용 ⭐️⭐️⭐️
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: goods.mainimage != null && goods.mainimage is Uint8List
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.memory(
                    goods.mainimage!,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goods.gname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              goods.gengname,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // 바텀 시트 내부 - 사이즈 옵션 위젯 (DB 데이터 사용)
  Widget _buildSizeOptions(StateSetter setModalState) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _availableSizes.map((size) {
        bool isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () {
            setModalState(() {
              _selectedSize = size;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.grey.shade800 : Colors.transparent,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 바텀 시트 내부 - 색상 옵션 위젯 (DB 데이터 사용)
  Widget _buildColorOptions(StateSetter setModalState) {
    return Wrap(
      spacing: 15.0,
      children: _availableColorMap.entries.map((entry) {
        String colorName = entry.key;
        Color colorValue = Color(entry.value);
        bool isSelected = _selectedColor == colorName;
        
        // 텍스트 색상 결정 (밝은 배경에 검은색, 어두운 배경에 흰색)
        Color checkColor = colorValue.computeLuminance() > 0.5 ? Colors.black : Colors.white;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setModalState(() {
                  _selectedColor = colorName;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorValue,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: isSelected ? 3.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: checkColor)
                    : null,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              colorName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // 바텀 시트 내부 - 수량 선택 위젯
  Widget _buildQuantitySelector(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 선택된 옵션 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${_selectedSize ?? '사이즈'} / ${_selectedColor ?? '색상'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 수량 조절 버튼
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
                    if (_purchaseQuantity > 1) {
                      setModalState(() {
                        _purchaseQuantity--;
                      });
                    }
                  },
                ),
                Text('$_purchaseQuantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    setModalState(() {
                      _purchaseQuantity++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 바텀 시트 내부 - 하단 버튼 바 (장바구니/구매)
  Widget _buildOptionBottomBar(BuildContext context) {
    return Row(
      children: [
        // 장바구니 담기 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // 옵션 선택 확인
              if (_selectedSize == null || _selectedColor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사이즈와 색상을 모두 선택해 주세요.')),
                  );
                  return;
              }
              
              // TODO: 장바구니 담기 로직
              Navigator.pop(context); // 시트 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.goods.gname} ($_selectedSize/$_selectedColor) $_purchaseQuantity개가 장바구니에 담겼습니다.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              '장바구니 담기',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 바로 구매하기 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // 옵션 선택 확인
              if (_selectedSize == null || _selectedColor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사이즈와 색상을 모두 선택해 주세요.')),
                  );
                  return;
              }
              
              Navigator.pop(context); // 시트 닫기
              // pay.dart 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayPage(
                    goods: widget.goods,
                    selectedSize: _selectedSize!, // Null-check 이후에 사용
                    selectedColor: _selectedColor!, // Null-check 이후에 사용
                    quantity: _purchaseQuantity,
                    userid: widget.userid,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              '바로 구매하기',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}