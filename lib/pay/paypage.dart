// lib/pay/paypage.dart 파일 전체 내용

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xyz_project_01/model/goods.dart'; // Goods 모델 경로 확인
import 'package:xyz_project_01/model/purchase.dart'; // Purchase 모델 경로 확인
import 'package:xyz_project_01/vm/database/purchase_database.dart'; // PurchaseDatabase 경로 확인
import 'package:xyz_project_01/vm/database/goods_database.dart'; // GoodsDatabase 경로 확인

class PayPage extends StatefulWidget {
  final Goods goods;
  final String selectedSize;
  final String selectedColor;
  final int quantity;

  const PayPage({
    super.key,
    required this.goods,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
  });

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  // ⭐️ 결제 방법 관리를 위한 상태 변수
  int _selectedPaymentMethod = 0; // 0: 간편 결제, 1: 신용카드, 2: 매장에서 결제
  
  // ⭐️ 금액 포맷 유틸리티 (Double -> Int로 변경)
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}원';
  }

  @override
  Widget build(BuildContext context) {
    // 상품 가격 (임시 값 사용 -> int로 변경)
    const int singlePrice = 150000; // GMain에서 사용한 고정 가격과 맞춤
    
    final int subtotal = singlePrice * widget.quantity;
    const int fee = 0; // 수수료 0으로 고정
    final int totalAmount = subtotal; // 총 결제금액 = 구매가

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
              _buildReceivingStoreSelection(), // 수령 매장 선택
              const SizedBox(height: 30),
              
              _buildPurchaseDetails(subtotal), // 구매 내역 확인
              const SizedBox(height: 30),
              
              _buildPaymentMethod(), // 결제 방법
              const SizedBox(height: 30),
              
              _buildOrderSummary(subtotal, totalAmount), // 최종 주문 정보
              const SizedBox(height: 120), // 하단 버튼 공간 확보
            ],
          ),
        ),
      ),
      // 5. 하단 결제 버튼 바
      bottomNavigationBar: _buildBottomCheckoutBar(totalAmount, context),
    );
  }

  // 수령 매장 선택 섹션
  Widget _buildReceivingStoreSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '수령매장 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // TODO: 매장 선택 페이지(GMap)로 이동 로직 구현
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '제품을 받을 매장을 선택하세요',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
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
              // ⭐️ DB 이미지 사용
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
                    Text(widget.goods.gname, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.goods.gengname, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text('옵션: ${widget.selectedSize} / ${widget.selectedColor}, 수량: ${widget.quantity}개', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    const Text('결제 금액'),
                    const SizedBox(height: 5),
                    Text(_formatCurrency(subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
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
        
        // 간편 결제
        _buildPaymentOption(title: '간편 결제', subtitle: '', value: 0),
        const Divider(),
        
        // 신용카드
        _buildPaymentOption(title: '신용카드', subtitle: '일시불 + 할부', value: 1),
        const Divider(),

        // 매장에서 결제
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
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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

  // ⭐️⭐️⭐️ 하단 결제 버튼 바 (DB 로직 실행) ⭐️⭐️⭐️
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
            // ⭐️ 결제 및 재고 처리 로직 실행
            _processPaymentAndSave(totalAmount, context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // ⭐️⭐️⭐️ 결제 처리 및 DB 저장 함수 ⭐️⭐️⭐️
  Future<void> _processPaymentAndSave(int finalPrice, BuildContext context) async {
      // 1. 선택된 결제 수단 매핑
      final int payWay;
      switch (_selectedPaymentMethod) {
        case 0: payWay = 1; break; // 간편 결제
        case 1: payWay = 2; break; // 신용카드
        case 2: payWay = 3; break; // 매장에서 결제 (현장결제)
        default: payWay = 1;
      }
      
      // 2. 현재 시간 포맷
      final now = DateTime.now();
      final DateFormat dbFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final String dateString = dbFormat.format(now);
      
      // 3. Purchase 객체 생성
      final newPurchase = Purchase(
        pstatus: 2, // 2: 결제 완료, 승인 대기
        pdate: dateString,
        pamount: widget.quantity, // 주문한 상품의 총 수량
        ppaydate: dateString,
        ppayprice: finalPrice.toDouble(), // 결제가격 (Double)
        ppayway: payWay,
        ppayamount: widget.quantity, // 결제 수량
        pdiscount: 0.0, // 할인율 0% 가정
      );

      // 4. DB 핸들러 호출
      final purchaseDB = PurchaseDatabase();
      final goodsDB = GoodsDatabase();

      try {
        // 4-1. Purchase 테이블에 주문 정보 입력
        int purchaseResult = await purchaseDB.insertPurchase(newPurchase);
        
        // 4-2. Goods 테이블에서 재고 차감 (현재 옵션의 gseq 사용)
        int goodsResult = await goodsDB.updateGoodsQuantity(
          gseq: widget.goods.gseq!, 
          quantityChange: -widget.quantity, // 구매 수량만큼 차감
        );

        if (purchaseResult > 0 && goodsResult > 0) {
          // 성공 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 결제가 완료되었으며 주문 정보가 저장되었습니다.')),
          );
          
          // 메인 화면으로 돌아가기
          Navigator.popUntil(context, (route) => route.isFirst); 

        } else {
          // DB 저장 실패 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ 결제는 완료되었으나 DB 저장/재고 차감에 실패했습니다.')),
          );
        }
        
      } catch (e) {
        // 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 결제 처리 중 오류 발생: ${e.toString()}')),
        );
      }
  }
}