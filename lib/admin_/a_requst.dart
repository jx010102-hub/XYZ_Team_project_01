import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ⭐️ 필수 import: 사용자님의 모델 및 DB 클래스 경로로 수정해야 합니다.
import 'package:xyz_project_01/model/purchase.dart'; // 주문 정보를 Purchase 모델로 사용
import 'package:xyz_project_01/model/goods.dart';   // 재고 확인용 Goods 모델
import 'package:xyz_project_01/vm/database/goods_database.dart'; 
import 'package:xyz_project_01/vm/database/purchase_database.dart'; // 주문 DB 사용

// =======================================================
// 1. ARequst 페이지 위젯 (Purchase DB 통합)
// =======================================================

class ARequst extends StatefulWidget {
  const ARequst({super.key});

  @override
  State<ARequst> createState() => _ARequstState();
}

class _ARequstState extends State<ARequst> {
  // ⭐️ DB 인스턴스
  final PurchaseDatabase _purchaseDB = PurchaseDatabase(); // 주문 정보 로드 및 상태 변경
  final GoodsDatabase _goodsDB = GoodsDatabase(); // 재고 차감용
  
  List<Purchase> _requests = []; // Purchase 모델 사용
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // 승인 대기 중인 주문 목록 로드 (PurchaseDatabase의 함수 사용)
  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      // ⭐️ PurchaseDatabase의 queryPendingPurchases 함수를 호출
      final loadedRequests = await _purchaseDB.queryPendingPurchases(); 
      
      setState(() {
        _requests = loadedRequests;
        _isLoading = false;
      });
    } catch (e) {
      print("결제 요청 로드 에러: $e");
      setState(() => _isLoading = false);
      Get.snackbar('오류', '주문 목록을 불러오지 못했습니다.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 특정 상품 옵션의 현재 재고 수량 확인 (GoodsDatabase 함수 사용)
  Future<int> _checkCurrentStock({
    required String gname,
    required String gsize,
    required String gcolor,
  }) async {
    // ⭐️ GoodsDatabase의 getGoodsVariant 함수를 사용하여 옵션별 재고 확인
    // Purchase 모델에는 gname, gsize, gcolor이 없으므로, 이 정보는
    // PurchaseItem(주문 상품 상세) 테이블에서 가져와야 하지만, 현재는 Purchase 테이블에
    // 주문 상품의 핵심 정보가 포함되어 있다고 임시 가정합니다.
    // **경고:** 실제 프로젝트에서는 Purchase와 Goods를 연결하는 PurchaseItem 테이블이 필요합니다.
    
    // 현재는 이 정보를 얻을 수 없으므로, 재고 확인 로직을 임시로 단순화하거나 
    // Purchase 모델에 gname, gsize, gcolor을 추가해야 합니다.
    // ⭐️ (임시) 0을 반환하여 재고 부족으로 간주합니다. 이 부분은 실제 DB 구조에 맞춰 수정되어야 합니다.
    return 100; // 충분한 재고가 있다고 가정하고 진행 (실제로는 GoodsDB 쿼리 필요)
  }

  // 요청 처리 (승인/거절)
  void _handleRequest(Purchase purchase, bool isApproved) async {
    setState(() => _isLoading = true);
    
    bool success = false;
    
    // ⭐️ 경고: Purchase 모델에는 gname, gsize, gcolor이 없으므로 재고 확인이 불가능합니다.
    // 이 예시에서는 재고 확인을 건너뛰거나, purchase.pamount를 기준으로만 처리합니다.
    final int requestedQty = purchase.pamount; 
    final int pseq = purchase.pseq!;
    
    if (isApproved) {
      // 1. 재고 차감 로직 (GoodsDB와 연동) - 여기서는 임시로 통과
      // ⭐️ 실제 로직: GoodsDB를 이용해 재고 차감 (Goods.gseq 필요)
      
      // 2. 주문 상태를 4 (물건 수령 완료)로 업데이트
      final int updateResult = await _purchaseDB.updatePurchaseToCompleted(pseq);

      if (updateResult > 0) {
        Get.snackbar('성공', '주문 #${pseq} 승인 완료! 상태가 수령 완료(4)로 변경되었습니다.', snackPosition: SnackPosition.BOTTOM);
        success = true;
      } else {
        Get.snackbar('실패', '주문 #${pseq} 상태 변경에 실패했습니다.', snackPosition: SnackPosition.BOTTOM);
      }
      
    } else {
      // 거절 로직 (상태를 '취소' 상태인 0 또는 -1 등으로 변경해야 함. Purchase 모델에는 정의되지 않았으므로 임시로 0 사용)
      await _purchaseDB.updatePurchaseStatus(pseq, 0); // 상태 0으로 변경 (취소/거절 가정)
      Get.snackbar('알림', '주문 #${pseq} 가 거절/취소 처리되었습니다.', snackPosition: SnackPosition.BOTTOM);
      success = true;
    }
    
    // 상태 업데이트 후 목록 새로고침
    if (success) {
        await _loadRequests();
    } else {
        setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 요청 승인', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadRequests,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('승인 대기 중인 결제 요청이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return _buildRequestCard(request);
                  },
                ),
    );
  }

  // 요청 목록 카드 위젯
  Widget _buildRequestCard(Purchase purchase) {
    // ⭐️ 재고 확인을 위한 임시 변수 (Purchase 모델에 상세 정보가 없으므로)
    final bool isStockSufficient = true; // 재고 확인 로직이 없으므로 항상 true로 가정
    final int requestedQty = purchase.pamount;
    final int currentStock = 100; // 임시값
    
    // ⭐️ pstatus 설명을 명확히 표시
    String getStatusDescription(int status) {
        switch (status) {
            case 2: return '결제 완료, 승인 대기';
            default: return '알 수 없음 ($status)';
        }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 주문 기본 정보
            Text(
              '주문 번호: #${purchase.pseq} | 주문일: ${purchase.pdate}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '주문 상태: ${getStatusDescription(purchase.pstatus)}',
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // 2. 주문 상세 정보 (Purchase 모델 정보 사용)
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '구매자 ID: ${purchase.userid}',
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• 총 주문 수량: ${purchase.pamount} 개', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('• 결제 금액: ${purchase.ppayprice.toStringAsFixed(0)} 원', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('• 결제일: ${purchase.ppaydate}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            
            const Divider(height: 20),
            
            // 3. 재고 확인 및 처리 버튼 영역
            // ⭐️ FutureBuilder를 제거하고 임시 재고 상태를 사용합니다.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStockSufficient 
                    ? '재고 상태: 충분 (임시: $currentStock개)'
                    : '재고 상태: 부족 (요청 $requestedQty개)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isStockSufficient ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 거절 버튼
                    OutlinedButton(
                      onPressed: () => _handleRequest(purchase, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('거절/취소 처리'),
                    ),
                    const SizedBox(width: 10),
                    
                    // 승인 버튼 (재고 부족 시 비활성화는 현재 임시로 해제)
                    ElevatedButton(
                      onPressed: isStockSufficient ? () => _handleRequest(purchase, true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('승인 (상태 4로 바로 변경)'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}