// lib/pay/paypage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:xyz_project_01/view/goods/g_map.dart';
import 'package:xyz_project_01/view/goods/g_tabbar.dart';

import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';
import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/controller/store_controller.dart';

import 'package:xyz_project_01/util/message.dart';

class PayPage extends StatefulWidget {
  final Goods goods;
  final String selectedSize;
  final String selectedColor;
  final int quantity;
  final String userid;

  const PayPage({
    super.key,
    required this.goods,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
    required this.userid,
  });

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  // 0: 간편결제, 1: 카드, 2: 매장
  int _selectedPaymentMethod = 0;

  final StoreController storeController = Get.find<StoreController>();
  final Message message = Message();

  static const int _fee = 0;

  final NumberFormat _currencyFormatter = NumberFormat('#,###');
  final DateFormat _dbFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String _formatCurrency(int amount) => '${_currencyFormatter.format(amount)}원';

  int _payWayFromSelected(int selected) {
    if (selected == 0) return 1;
    if (selected == 1) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final int unitPrice = widget.goods.price > 0
      ? widget.goods.price.toInt()
      : 0;
    final int subtotal = unitPrice * widget.quantity;
    final int totalAmount = subtotal + _fee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceivingStoreSelection(),
              const Padding(padding: EdgeInsets.only(top: 30)),
              _buildPurchaseDetails(subtotal),
              const Padding(padding: EdgeInsets.only(top: 30)),
              _buildPaymentMethod(),
              const Padding(padding: EdgeInsets.only(top: 30)),
              _buildOrderSummary(subtotal, totalAmount),
              const Padding(padding: EdgeInsets.only(top: 120)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCheckoutBar(totalAmount, context),
    );
  }

  Widget _buildReceivingStoreSelection() {
    return Obx(() {
      final store = storeController.selectedStore.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수령매장 선택',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),

          if (store != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['name'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4)),
                  Text(
                    '${store['district']} · ${store['address']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '수령할 매장을 선택해 주세요.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],

          ElevatedButton(
            onPressed: () => Get.to(GMap(userid: widget.userid)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white),
                const Padding(padding: EdgeInsets.only(left: 8)),
                Text(
                  store == null ? '제품을 받을 매장을 선택하세요' : '수령 매장 변경하기',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPurchaseDetails(int subtotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '구매 내역 확인',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '총 ${widget.quantity}건',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 15)),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: widget.goods.mainimage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.memory(
                          widget.goods.mainimage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goods.gname,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.goods.gengname,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      '옵션: ${widget.selectedSize} / ${widget.selectedColor}, 수량: ${widget.quantity}개',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('결제 금액'),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Text(
                    _formatCurrency(subtotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '결제 방법',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        _buildPaymentOption(title: '간편 결제', subtitle: '', value: 0),
        const Divider(),
        _buildPaymentOption(title: '신용카드', subtitle: '일시불 + 할부', value: 1),
        const Divider(),
        _buildPaymentOption(title: '매장에서 결제', subtitle: '현금 + 카드', value: 2),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = value),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedPaymentMethod = v);
              },
              activeColor: Colors.black,
            ),
            const Padding(padding: EdgeInsets.only(left: 5)),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(int subtotal, int totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최종 주문 정보',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Padding(padding: EdgeInsets.only(top: 15)),
        _buildSummaryRow('구매가', _formatCurrency(subtotal)),
        const Divider(height: 30, thickness: 1.5),
        _buildSummaryRow('총 결제금액', _formatCurrency(totalAmount), isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.black : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: isTotal ? Colors.red : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(int totalAmount, BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton(
          onPressed: () {
            if (storeController.selectedStore.value == null) {
              message.warning('매장 선택', '먼저 수령 매장을 선택해 주세요.');
              return;
            }
            _processPaymentAndSave(totalAmount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            '${_formatCurrency(totalAmount)} 결제요청하기',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPaymentAndSave(int finalPrice) async {
    if (storeController.selectedStore.value == null) {
      message.warning('매장 선택', '수령 매장을 먼저 선택해 주세요.');
      return;
    }

    // gseq 확정: DB에서 해당 옵션 다시 조회
    final goodsDB = GoodsDatabase();
    final variant = await goodsDB.getGoodsVariant(
      gname: widget.goods.gname,
      gsize: widget.selectedSize,
      gcolor: widget.selectedColor,
    );

    if (!mounted) return;

    if (variant == null || variant.gseq == null) {
      message.error('옵션 오류', '상품 옵션을 DB에서 찾을 수 없습니다. (gseq 없음)');
      return;
    }

    final int payWay = _payWayFromSelected(_selectedPaymentMethod);

    final now = DateTime.now();
    final dateString = _dbFormat.format(now);

    final newPurchase = Purchase(
      pstatus: 2,
      pdate: dateString,
      pamount: widget.quantity,
      ppaydate: dateString,
      ppayprice: finalPrice.toDouble(),
      ppayway: payWay,
      ppayamount: widget.quantity,
      pdiscount: 0.0,
      userid: widget.userid,

      gseq: variant.gseq,
      gsize: widget.selectedSize,
      gcolor: widget.selectedColor,
    );

    final purchaseDB = PurchaseDatabase();

    try {
      final purchaseResult = await purchaseDB.insertPurchase(newPurchase);

      if (!mounted) return;

      if (purchaseResult > 0) {
        Get.defaultDialog(
          title: '완료',
          middleText: '결제 요청이 등록되었습니다.\n(승인 후 재고가 차감됩니다)',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () => Get.offAll(GTabbar(userid: widget.userid)),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('OK'),
            ),
          ],
        );
      } else {
        message.error('실패', '결제 요청 등록에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      message.error('오류', '결제 처리 중 오류 발생: $e');
    }
  }
}
