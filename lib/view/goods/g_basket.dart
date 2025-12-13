import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/controller/store_controller.dart';

// 장바구니 항목 데이터 구조
class BasketItem {
  final int id;
  final String name;
  final String engName;
  final String imagePath;
  final double price; // 상품 개별 가격
  int quantity; // 수량 (수정 가능)
  bool isChecked; // 선택 상태

  BasketItem({
    required this.id,
    required this.name,
    required this.engName,
    required this.imagePath,
    required this.price,
    this.quantity = 1,
    this.isChecked = true,
  });
}

class GBasket extends StatefulWidget {
  final String userid;
  const GBasket({super.key, required this.userid});

  @override
  State<GBasket> createState() => _GBasketState();
}

class _GBasketState extends State<GBasket> {
  final StoreController storeController = Get.find<StoreController>();

  // 장바구니 목록
  final List<BasketItem> _items = [];

  // 총 금액/수량
  double _totalPrice = 0;
  int _totalQuantity = 0;

  @override
  void initState() {
    super.initState();

    // 초기 더미 데이터
    _items.addAll([
      BasketItem(
        id: 1,
        name: '나이키 매직포스 파워레인저 화이트',
        engName: 'Nike Magic Force Power Rangers White',
        imagePath: 'images/shoe1.png',
        price: 100000,
        quantity: 1,
        isChecked: true,
      ),
      BasketItem(
        id: 2,
        name: '아디다스 퓨처러너 블랙',
        engName: 'Adidas Future Runner Black',
        imagePath: 'images/shoe2.png',
        price: 109200,
        quantity: 2,
        isChecked: true,
      ),
    ]);

    _recalcTotals();
  }

  // 총액/수량 계산 (setState 밖에서 값만 계산)
  void _recalcTotals() {
    double newTotal = 0;
    int newQuantity = 0;

    for (final item in _items) {
      if (item.isChecked) {
        newTotal += item.price * item.quantity;
        newQuantity += item.quantity;
      }
    }

    _totalPrice = newTotal;
    _totalQuantity = newQuantity;
  }

  void _applyTotals() {
    setState(() {
      _recalcTotals();
    });
  }

  // 수량 업데이트
  void _updateQuantity(BasketItem item, int change) {
    setState(() {
      final newQuantity = item.quantity + change;
      if (newQuantity >= 1) {
        item.quantity = newQuantity;
        _recalcTotals();
      }
    });
  }

  // 금액 포맷
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.round())}원';
  }

  // 아직 구현 안 된 기능 다이얼로그
  void _showNotImplementedDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(action),
          content: const Text('현재 해당 기능은 구현 중입니다. 🚧'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 장바구니 카드 1개
  Widget _buildBasketItem(BasketItem item) {
    final itemTotalPrice = item.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // 1) 체크박스 / 상품 정보 / 삭제
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        item.isChecked = !item.isChecked;
                        _recalcTotals();
                      });
                    },
                    child: Icon(
                      item.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                      color: item.isChecked ? Colors.black : Colors.grey,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.engName,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _showNotImplementedDialog(context, '항목 삭제'),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),

              const Divider(height: 30, thickness: 1, color: Colors.black12),

              // 2) 수량 조절 / 총 상품 금액
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () => _updateQuantity(item, -1),
                          color: item.quantity > 1 ? Colors.black : Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => _updateQuantity(item, 1),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('총 상품 금액', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _formatCurrency(itemTotalPrice),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 3) 옵션 변경 / 바로 주문
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showNotImplementedDialog(context, '옵션 변경'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('옵션변경'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: () => _showNotImplementedDialog(context, '바로 주문'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('바로주문'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png',
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            ..._items.map(_buildBasketItem),

            // bottomSheet 영역과 겹침 방지용 패딩
            const Padding(
              padding: EdgeInsets.only(bottom: 100),
            ),
          ],
        ),
      ),

      bottomSheet: Obx(() {
        final store = storeController.selectedStore.value;

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 구매하기 영역
              GestureDetector(
                onTap: () {
                  // totals 최신 반영 보장
                  _applyTotals();
                  _showNotImplementedDialog(context, '총 $_totalQuantity개 상품 구매하기');
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: const Color(0xFFE53935),
                  alignment: Alignment.center,
                  child: Text(
                    '${_formatCurrency(_totalPrice)} · 총 $_totalQuantity개 상품 구매하기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 선택 매장 정보 (있을 때만)
              if (store != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.store, color: Colors.black87, size: 20),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['name'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                '${store['district']} · ${store['address']}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showNotImplementedDialog(context, '매장 변경하기'),
                        child: const Text(
                          '변경',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
