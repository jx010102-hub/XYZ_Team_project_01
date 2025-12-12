// lib/vm/database/purchase_database.dart (최종 수정)

import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/purchase.dart'; 
import 'package:xyz_project_01/vm/database/database_handler.dart'; 

class PurchaseDatabase {
  
  final DatabaseHandler handler = DatabaseHandler(); 

  // 1. 구매 데이터를 DB에 삽입하는 메서드
  Future<int> insertPurchase(Purchase purchase) async {
    final db = await handler.initializeDB();
    
    final purchaseMap = purchase.toMap();
    purchaseMap.remove('pseq'); 

    int result = await db.insert(
      'purchase', 
      purchaseMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return result; 
  }


  // ⭐️ 2. 상태에 따라 조회 가능한 구매 내역 조회 메서드 (SQL 컬럼명 수정)
  Future<List<Purchase>> queryPurchasesForUser(String userId, {int? status}) async {
    final db = await handler.initializeDB(); 
    
    // ⭐️ 오류 수정: cemail 대신 userid를 사용하도록 쿼리를 수정합니다.
    String sql = "SELECT * FROM purchase WHERE userid = ?";
    List<dynamic> args = [userId];

    if (status != null) {
      sql += " AND pstatus = ?";
      args.add(status);
    }
    
    sql += " ORDER BY pseq DESC";

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    
    return List.generate(maps.length, (i) {
      return Purchase.fromMap(maps[i]);
    });
  }
  
  Future<List<Purchase>> queryPurchaseByUserId(String userId) async {
      return queryPurchasesForUser(userId);
  }

  // lib/vm/database/purchase_database.dart 에 추가해야 할 내용 가정

// 3. 주문 상태 업데이트 (취소 시 사용)
Future<int> updatePurchaseStatus(int pseq, int newStatus) async {
  final db = await handler.initializeDB();
  return await db.update(
    'purchase', 
    {'pstatus': newStatus}, 
    where: 'pseq = ?', 
    whereArgs: [pseq]
  );
}
}