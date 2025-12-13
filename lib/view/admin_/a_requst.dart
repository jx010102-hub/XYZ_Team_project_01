import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ⭐️ 필수 import: 사용자님의 모델 및 DB 클래스 경로로 수정해야 합니다.
import 'package:xyz_project_01/model/purchase.dart'; 
import 'package:xyz_project_01/model/goods.dart'; 
import 'package:xyz_project_01/vm/database/goods_database.dart'; 
import 'package:xyz_project_01/vm/database/purchase_database.dart'; 

// =======================================================
// 1. UI 표시를 위한 임시 데이터 모델 (Purchase와 Goods 정보 결합)
// =======================================================
class PurchaseRequestDetail {
  final Purchase purchase;
  final Goods? goods; 
  final int currentStock;
  final bool isStockSufficient;
  
  PurchaseRequestDetail({
    required this.purchase,
    this.goods,
    required this.currentStock,
    required this.isStockSufficient,
  });
}


class ARequst extends StatefulWidget {
  const ARequst({super.key});

  @override
  State<ARequst> createState() => _ARequstState();
}


class _ARequstState extends State<ARequst> {
  final PurchaseDatabase _purchaseDB = PurchaseDatabase();
  final GoodsDatabase _goodsDB = GoodsDatabase(); 
  
  List<PurchaseRequestDetail> _requestDetails = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }
  
  // ⭐️ 핵심 로직: 주문 목록 로드 및 재고 정보 결합 (오류 회피 버전)
  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. 승인 대기 중인 주문(Purchase) 목록 로드
      final List<Purchase> pendingPurchases = await _purchaseDB.queryPendingPurchases(); 
      
      List<PurchaseRequestDetail> newDetails = [];

      // 2. 각 주문에 대해 상품 정보와 재고를 비동기적으로 조회
      for (final purchase in pendingPurchases) {
        
        Goods? goodsVariant;
        int currentStock = 0;
        
        try {
            // ⭐️ STEP A: pseq를 이용해 Goods ID(gseq)를 찾아오는 중재자 함수 호출
            final int? goodsId = await _goodsDB.getGoodsIdByPurchaseId(purchase.pseq!); 
            
            if (goodsId != null) {
                // ⭐️ STEP B: Goods ID를 통해 해당 상품 옵션 정보를 가져옴 (gsumamount 포함)
                goodsVariant = await _goodsDB.getGoodsByGseq(goodsId);
                currentStock = goodsVariant?.gsumamount ?? 0;
            }
        } catch (e) {
            // ⭐️ 상품 정보 로드 중 오류 발생 (예: purchase_item 테이블 이름 불일치)
            print('주문 #${purchase.pseq}의 상품 정보 로드 중 오류 발생: $e');
            // 오류가 발생해도 주문 목록 로드는 계속 진행
            goodsVariant = null; 
            currentStock = 0;
        }

        final bool isSufficient = currentStock >= purchase.pamount;
        
        newDetails.add(
          PurchaseRequestDetail(
            purchase: purchase,
            goods: goodsVariant,
            currentStock: currentStock,
            isStockSufficient: isSufficient,
          ),
        );
      }
      
      setState(() {
        _requestDetails = newDetails;
        _isLoading = false;
      });
      
    } catch (e) {
      // ⭐️ Purchase 목록 로드 자체에서 오류가 발생한 경우 (예: purchase 테이블 오류)
      print("결제 요청 목록 로드 자체에서 에러 발생: $e");
      setState(() => _isLoading = false);
      Get.snackbar('오류', '주문 목록을 불러오지 못했습니다. DB 쿼리(pstatus=2)를 확인하세요.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ⭐️ 요청 처리 (승인/거절)
  void _handleRequest(PurchaseRequestDetail detail, bool isApproved) async {
    setState(() => _isLoading = true);
    
    bool success = false;
    final purchase = detail.purchase;
    final int pseq = purchase.pseq!;
    
    if (isApproved) {
      
      // 1. 재고 상태 및 상품 정보 재확인
      if (detail.goods == null || detail.goods!.gseq == null) {
        Get.snackbar('실패', '주문 #$pseq 승인 실패: 상품 정보를 찾을 수 없습니다.', snackPosition: SnackPosition.BOTTOM);
      } else if (!detail.isStockSufficient) {
        Get.snackbar('실패', '주문 #$pseq 승인 실패: 재고 부족 (${detail.currentStock} < ${purchase.pamount})', snackPosition: SnackPosition.BOTTOM);
      } else {
        // 2. 재고 차감 로직 실행
        final int goodsUpdateResult = await _goodsDB.updateGoodsQuantity(
          gseq: detail.goods!.gseq!,
          quantityChange: -purchase.pamount, // 주문 수량만큼 감소
        );

        if (goodsUpdateResult > 0) {
          // 3. 재고 차감 성공 시, 주문 상태를 4 (물건 수령 완료)로 업데이트
          final int updateResult = await _purchaseDB.updatePurchaseToCompleted(pseq);

          if (updateResult > 0) {
            Get.snackbar('성공', '주문 #$pseq 승인 완료 및 재고 차감되었습니다. (상태 4)', snackPosition: SnackPosition.BOTTOM);
            success = true;
          } else {
            Get.snackbar('실패', '주문 #$pseq 상태 변경 실패. 재고는 차감되었을 수 있습니다.', snackPosition: SnackPosition.BOTTOM);
          }
        } else {
             Get.snackbar('실패', '주문 #$pseq 승인 실패: 재고 차감 DB 오류', snackPosition: SnackPosition.BOTTOM);
        }
      }
      
    } else {
      // 거절 로직
      await _purchaseDB.updatePurchaseStatus(pseq, 0); // 상태 0으로 변경 (취소/거절 가정)
      Get.snackbar('알림', '주문 #$pseq 가 거절/취소 처리되었습니다.', snackPosition: SnackPosition.BOTTOM);
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
          : _requestDetails.isEmpty
              ? const Center(child: Text('승인 대기 중인 결제 요청이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requestDetails.length,
                  itemBuilder: (context, index) {
                    final detail = _requestDetails[index];
                    return _buildRequestCard(detail);
                  },
                ),
    );
  }

  // ⭐️ 요청 목록 카드 위젯 - PurchaseRequestDetail 객체를 사용
  Widget _buildRequestCard(PurchaseRequestDetail detail) {
    final purchase = detail.purchase;
    final goods = detail.goods;
    final int requestedQty = purchase.pamount;
    
    // 상품 정보 표시
    final String optionInfo = goods == null 
        ? '상품 정보 조회 불가 (Goods 연결 오류)' 
        : '${goods.gname} (${goods.gsize} / ${goods.gcolor})';

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
            const SizedBox(height: 8),
            
            // 2. 상품 상세 정보 (Goods 정보)
            Text(
              '상품 옵션: $optionInfo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, 
                   color: goods == null ? Colors.orange.shade700 : Colors.blueGrey),
            ),
            
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• 총 주문 수량: $requestedQty 개', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('• 구매자 ID: ${purchase.userid}', style: const TextStyle(color: Colors.grey)),
                  Text('• 결제 금액: ${purchase.ppayprice.toStringAsFixed(0)} 원', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            
            const Divider(height: 20),
            
            // 3. 재고 확인 및 처리 버튼 영역
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 재고 (gsumamount): ${detail.currentStock} 개',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: detail.isStockSufficient ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 거절 버튼
                    OutlinedButton(
                      onPressed: () => _handleRequest(detail, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('거절/취소 처리'),
                    ),
                    const SizedBox(width: 10),
                    
                    // 승인 버튼 (재고 부족 또는 상품 정보 없을 시 비활성화)
                    ElevatedButton(
                      onPressed: detail.isStockSufficient && goods != null ? () => _handleRequest(detail, true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: detail.isStockSufficient && goods != null ? Colors.black : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(detail.isStockSufficient && goods != null ? '승인 (상태 4로 변경)' : '재고/정보 부족'),
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