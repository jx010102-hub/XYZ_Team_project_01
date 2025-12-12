import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xyz_project_01/goods/g_map.dart';
import 'package:xyz_project_01/goods/g_tabbar.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/vm/database/purchase_database.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';
import 'package:xyz_project_01/controller/store_controller.dart';


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
  // 결제 방법 상태
  int _selectedPaymentMethod = 0; // 0: 간편 결제, 1: 신용카드, 2: 매장에서 결제

  // ✅ 전역 매장 컨트롤러
  final StoreController storeController = Get.find<StoreController>();

  // 금액 포맷 유틸
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}원';
  }

  @override
  Widget build(BuildContext context) {
    const int singlePrice = 150000; // 상품 단가 (임시)
    final int subtotal = singlePrice * widget.quantity;
    const int fee = 0;
    final int totalAmount = subtotal + fee;

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
              const SizedBox(height: 30),
              _buildPurchaseDetails(subtotal),
              const SizedBox(height: 30),
              _buildPaymentMethod(),
              const SizedBox(height: 30),
              _buildOrderSummary(subtotal, totalAmount),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCheckoutBar(totalAmount, context),
    );
  }

  // ✅ 수령 매장 선택 섹션
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
          const SizedBox(height: 10),

          // ✅ 선택된 매장 정보 표시
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
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
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

          // ✅ 매장 선택/변경 버튼 (선택 여부와 상관없이 사용)
          ElevatedButton(
            onPressed: () {
              // 매장 선택 페이지로 이동 (선택 후 돌아오면 Obx가 자동 갱신)
              Get.to(GMap(userid: widget.userid));
            },
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
                const SizedBox(width: 8),
                Text(
                  store == null
                      ? '제품을 받을 매장을 선택하세요'
                      : '수령 매장 변경하기',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
  // 구매 내역 확인 섹션
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
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품 이미지
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
              const SizedBox(width: 10),
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
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '옵션: ${widget.selectedSize} / ${widget.selectedColor}, 수량: ${widget.quantity}개',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('결제 금액'),
                  const SizedBox(height: 5),
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

  // 결제 방법 섹션
  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '결제 방법',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildPaymentOption(title: '간편 결제', subtitle: '', value: 0),
        const Divider(),
        _buildPaymentOption(
          title: '신용카드',
          subtitle: '일시불 + 할부',
          value: 1,
        ),
        const Divider(),
        _buildPaymentOption(
          title: '매장에서 결제',
          subtitle: '현금 + 카드',
          value: 2,
        ),
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
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
              activeColor: Colors.black,
            ),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 최종 주문 정보 섹션
  Widget _buildOrderSummary(int subtotal, int totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최종 주문 정보',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildSummaryRow('구매가', _formatCurrency(subtotal)),
        const Divider(height: 30, thickness: 1.5),
        _buildSummaryRow(
          '총 결제금액',
          _formatCurrency(totalAmount),
          isTotal: true,
        ),
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

  // 하단 결제 버튼 바
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
            // ✅ 매장 선택 안 했으면 결제 막기 (컨트롤러 기준으로 체크)
            if (storeController.selectedStore.value == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('먼저 수령 매장을 선택해 주세요.'),
                ),
              );
              return;
            }
            _processPaymentAndSave(totalAmount, context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            '${_formatCurrency(totalAmount)} 결제하기',
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

  // 결제 처리 및 DB 저장
  Future<void> _processPaymentAndSave(

      int finalPrice, BuildContext context) async {
    if (storeController.selectedStore.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수령 매장을 먼저 선택해 주세요.')),
      );
      return;
    }
    // 1. 결제 수단 매핑
    final int payWay;
    switch (_selectedPaymentMethod) {
      case 0:
        payWay = 1;
        break; // 간편 결제
      case 1:
        payWay = 2;
        break; // 신용카드
      case 2:
        payWay = 3;
        break; // 매장에서 결제
      default:
        payWay = 1;
    }

    // 2. 현재 시간
    final now = DateTime.now();
    final DateFormat dbFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String dateString = dbFormat.format(now);

    // 3. Purchase 객체 생성 (매장 정보는 DB에 컬럼이 있어야 추가 가능)
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
    );

    final purchaseDB = PurchaseDatabase();
    final goodsDB = GoodsDatabase();

    try {
      int purchaseResult = await purchaseDB.insertPurchase(newPurchase);

      int goodsResult = await goodsDB.updateGoodsQuantity(
        gseq: widget.goods.gseq!,
        quantityChange: -widget.quantity,
      );

      if (purchaseResult > 0 && goodsResult > 0) {
        setState(() {
          widget.goods.gsumamount -= widget.quantity;
        });

        Get.defaultDialog(
          title: '성공',
          middleText: '결제가 완료되었습니다.',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(
                  GTabbar(userid: widget.userid),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('OK'),
            ),
          ],
        );
        print('${widget.userid}님 결제 완료');
        print('${widget.quantity}개 차감');
        print('남은 재고 ${widget.goods.gsumamount}개');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ 결제는 완료되었으나 DB 저장/재고 차감에 실패했습니다.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 결제 처리 중 오류 발생: $e'),
        ),
      );
    }
  }
}
