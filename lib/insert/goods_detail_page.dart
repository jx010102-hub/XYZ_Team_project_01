// g_detail.dart (또는 GoodsDetailPage가 정의된 파일)

import 'package:flutter/material.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/pay/paypage.dart'; // ⭐️ pay.dart 임포트 경로 확인

class GoodsDetailPage extends StatefulWidget {
  final Goods goods;

  const GoodsDetailPage({super.key, required this.goods});

  @override
  State<GoodsDetailPage> createState() =>
      _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  int _currentImageIndex = 0;

  final List<String> shoeImages = [
    'images/detail_shoe_1.png',
    'images/detail_shoe_2.png',
    'images/detail_shoe_3.png',
  ];

  // ⭐️ 옵션 상태 관리 변수
  String? _selectedSize;
  String? _selectedColor;
  int _purchaseQuantity = 1;
  
  // ⭐️ 가상의 상품 재고 및 옵션 데이터
  final List<String> _availableSizes = ['230', '240', '250', '260', '270', '280', '290', '300'];
  final List<Map<String, dynamic>> _availableColors = [
    {'name': '그레이', 'hex': 0xFFCCCCCC}, 
    {'name': '실버', 'hex': 0xFFBDBDBD},
    {'name': '화이트', 'hex': 0xFFFFFFFF},
    {'name': '블랙', 'hex': 0xFF000000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
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
              Icons.home_outlined,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImageSection(), // 3. 이미지/슬라이더 섹션
            _buildPriceAndNameSection(), // 4. 가격 및 이름 섹션
            // TODO: 여기에 다른 상세 정보 섹션 추가 (옵션, 리뷰 등)
            const SizedBox(height: 100), // 바닥 여백 확보
          ],
        ),
      ),
      // 5. 하단 고정 구매 버튼 바
      bottomNavigationBar: _buildBottomPurchaseBar(context),
    );
  }

  // 기존 위젯 함수들 (_buildProductImageSection, _buildPriceAndNameSection, _buildTag, _buildIndicator) 유지

  Widget _buildProductImageSection() {
    return SizedBox(
      height: 400, // 이미지 영역 높이
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 실제 이미지 슬라이더 (PageView)
          PageView.builder(
            itemCount: shoeImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex =
                    index; // 페이지 변경 시 인덱스 업데이트
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                shoeImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
                // 이미지가 로드되지 않을 경우 대비
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              );
            },
          ),

          // 2. 좋아요/공유 버튼 (디자인 이미지 참조)
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  // '좋아요' 버튼
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.thumb_up_alt_outlined,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  // '제품상세 >' 버튼
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    '제품상세 >',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
                shoeImages.length,
                (index) => _buildIndicator(
                  index == _currentImageIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndNameSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그 (주간전체 1위, Top 100. 스니커즈)
          Row(
            children: [
              _buildTag('주간전체 1위'),
              const SizedBox(width: 8),
              _buildTag(
                'Top 100. ${widget.goods.gcategory}',
              ), // Goods 모델의 카테고리 사용
            ],
          ),
          const SizedBox(height: 15),

          // 가격 (Goods 모델에 가격 필드가 없으므로 임시 값 사용)
          const Text(
            "100,000원",
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

          // 별점 및 리뷰 수 (디자인 이미지 참조)
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 5),
              const Text(
                '4.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
  
  // ⭐️ 하단 고정 구매 버튼 바
  Widget _buildBottomPurchaseBar(BuildContext context) {
    return Container(
      height: 80, // 하단 바 높이
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          // 1. 좋아요 버튼 (좌측)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 15),

          // 2. 구매하기 버튼 (우측)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // ⭐️ 구매하기 버튼 클릭 시 옵션 선택 바텀 시트 호출
                _showPurchaseOptions(context); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
    // 옵션 초기화 (선택이 없었다면)
    if (_selectedSize == null && _availableSizes.isNotEmpty) {
      _selectedSize = _availableSizes.first;
    }
    if (_selectedColor == null && _availableColors.isNotEmpty) {
      _selectedColor = _availableColors.first['name'] as String;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75, 
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                    height: 100, // 사이즈 옵션이 많을 경우 스크롤 가능하게 제한
                    child: SingleChildScrollView(
                      child: _buildSizeOptions(setModalState),
                    ),
                  ),
                  
                  const Divider(height: 30),
                  
                  // 3. 색상 옵션
                  const Text('색깔', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildColorOptions(setModalState),

                  // 4. 수량 선택 섹션 (사진과 같은 UI 구현)
                  if (_selectedSize != null && _selectedColor != null)
                    _buildQuantitySelector(setModalState),

                  const Spacer(),
                  
                  // 5. 하단 버튼 바 (장바구니 담기, 바로 구매하기)
                  _buildOptionBottomBar(context),
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
        Image.asset('images/shoe1.png', width: 60, height: 60), // 임시 이미지 경로
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goods.gname, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(goods.gengname, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
  
  // 바텀 시트 내부 - 사이즈 옵션 위젯
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
              border: Border.all(color: isSelected ? Colors.grey.shade800 : Colors.transparent),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 바텀 시트 내부 - 색상 옵션 위젯
  Widget _buildColorOptions(StateSetter setModalState) {
    return Wrap(
      spacing: 15.0,
      children: _availableColors.map((colorMap) {
        String colorName = colorMap['name'] as String;
        Color colorValue = Color(colorMap['hex'] as int);
        bool isSelected = _selectedColor == colorName;

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
                    ? Icon(Icons.check, color: colorValue.computeLuminance() > 0.5 ? Colors.black : Colors.white) 
                    : null,
              ),
            ),
            const SizedBox(height: 5),
            Text(colorName, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.grey)),
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
          // 선택된 옵션 정보 (디자인과 유사하게 S 또는 옵션 표시)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${_selectedSize ?? '사이즈'} / ${_selectedColor ?? '색상'}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
              // TODO: 장바구니 담기 로직
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.goods.gname} (${_selectedSize}/${_selectedColor}) ${_purchaseQuantity}개가 장바구니에 담겼습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('장바구니 담기', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 10),
        
        // 바로 구매하기 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 시트 닫기
              // pay.dart 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayPage(
                    goods: widget.goods,
                    selectedSize: _selectedSize ?? _availableSizes.first,
                    selectedColor: _selectedColor ?? _availableColors.first['name'] as String,
                    quantity: _purchaseQuantity,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('바로 구매하기', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}