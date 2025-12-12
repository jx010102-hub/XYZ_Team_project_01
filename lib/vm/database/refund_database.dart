// lib/vm/database/refund_database.dart (최종 수정)

import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart'; 

class RefundDatabase {
  
  // DatabaseHandler가 초기화 로직을 담당한다고 가정
  final DatabaseHandler handler = DatabaseHandler(); 
  
  // 반품 요청 삽입
  Future<int> insertRefund(Refund refund) async {
    final db = await handler.initializeDB();
    
    final refundMap = refund.toMap();
    refundMap.remove('rseq'); 
    
    int result = await db.insert(
        'refund', 
        refundMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  // ⭐️ 사용자 반품 내역 조회 (SQL 컬럼명 수정)
  Future<List<Refund>> queryRefundsByUserId(String userId) async {
    final db = await handler.initializeDB();
    
    // ⭐️ 오류 수정: p.cemail 대신 p.userid를 사용하도록 쿼리를 수정합니다.
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
        SELECT r.* FROM refund r
        JOIN purchase p ON r.rpseq = p.pseq
        WHERE p.userid = ?  
        ORDER BY r.rseq DESC
      """,
      [userId]
    );

    return List.generate(maps.length, (i) {
      return Refund.fromMap(maps[i]);
    });
  }
}