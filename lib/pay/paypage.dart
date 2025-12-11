// pay.dart (goods 폴더 내에 생성)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xyz_project_01/model/goods.dart'; // Goods 모델 경로 확인

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
  
  // ⭐️ 금액 포맷 유틸리티
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.round())}원';
  }

  @override
  Widget build(BuildContext context) {
    // 상품 가격 (Goods 모델에 가격 필드가 없으므로 임시 값 사용)
    const double singlePrice = 100000;
    
    // ⭐️ 수수료 제거: feeRate 및 fee 계산 제거
    final double subtotal = singlePrice * widget.quantity;
    const double fee = 0; // 수수료 0으로 고정
    final double totalAmount = subtotal; // 총 결제금액 = 구매가

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
              
              _buildOrderSummary(subtotal, fee, totalAmount), // 최종 주문 정보
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
  Widget _buildPurchaseDetails(double subtotal) {
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
              Image.asset('images/shoe1.png', width: 60, height: 60), // 임시 이미지
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
        _buildPaymentOption(
          title: '간편 결제', 
          subtitle: '', 
          value: 0
        ),
        const Divider(),
        
        // 신용카드
        _buildPaymentOption(
          title: '신용카드', 
          subtitle: '일시불 + 할부', 
          value: 1
        ),
        const Divider(),

        // 매장에서 결제
        _buildPaymentOption(
          title: '매장에서 결제', 
          subtitle: '현금 + 카드', 
          value: 2
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
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ⭐️ 최종 주문 정보 섹션 (수수료 행 제거)
  Widget _buildOrderSummary(double subtotal, double fee, double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최종 주문 정보',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        
        _buildSummaryRow('구매가', _formatCurrency(subtotal)),
        // ❌ 수수료 항목 제거
        
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
  Widget _buildBottomCheckoutBar(double totalAmount, BuildContext context) {
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
            // TODO: 실제 결제 승인 로직 구현
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_formatCurrency(totalAmount)} 결제 요청이 전송되었습니다.')),
            );
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
}