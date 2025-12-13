import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class PurchaseDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  // 1) 결제요청(=purchase 생성)
  Future<int> insertPurchase(Purchase purchase) async {
    final db = await handler.initializeDB();

    final map = purchase.toMap();
    map.remove('pseq');

    return await db.insert(
      'purchase',
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // 유저 구매내역 조회
  Future<List<Purchase>> queryPurchasesForUser(String userId, {int? status}) async {
    final db = await handler.initializeDB();

    String sql = "SELECT * FROM purchase WHERE userid = ?";
    final args = <dynamic>[userId];

    if (status != null) {
      sql += " AND pstatus = ?";
      args.add(status);
    }

    sql += " ORDER BY pseq DESC";

    final maps = await db.rawQuery(sql, args);
    return maps.map((e) => Purchase.fromMap(e)).toList();
  }

  Future<List<Purchase>> queryPurchaseByUserId(String userId) async {
    return queryPurchasesForUser(userId);
  }

  // ✅ (추가) pseq로 단건 조회: refund.rpseq -> purchase 조인용
  Future<Purchase?> queryPurchaseByPseq(int pseq) async {
    final db = await handler.initializeDB();
    final maps = await db.query(
      'purchase',
      where: 'pseq = ?',
      whereArgs: [pseq],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Purchase.fromMap(maps.first);
  }

  // 상태 변경
  Future<int> updatePurchaseStatus(int pseq, int newStatus) async {
    final db = await handler.initializeDB();
    return await db.update(
      'purchase',
      {'pstatus': newStatus},
      where: 'pseq = ?',
      whereArgs: [pseq],
    );
  }

  // 승인 대기 목록(pstatus=2)
  Future<List<Purchase>> queryPendingPurchases() async {
    final db = await handler.initializeDB();
    final maps = await db.query(
      'purchase',
      where: 'pstatus = ?',
      whereArgs: [2],
      orderBy: 'pdate DESC',
    );
    return maps.map((e) => Purchase.fromMap(e)).toList();
  }

  // ✅ 승인 처리: 3으로 변경
  Future<int> updatePurchaseToApproved(int pseq) async {
    final db = await handler.initializeDB();
    return await db.update(
      'purchase',
      {'pstatus': 3},
      where: 'pseq = ?',
      whereArgs: [pseq],
    );
  }

  // ✅ 수령 완료: 4로 변경
  Future<int> updatePurchaseToReceived(int pseq) async {
    final db = await handler.initializeDB();
    return await db.update(
      'purchase',
      {'pstatus': 4},
      where: 'pseq = ?',
      whereArgs: [pseq],
    );
  }
  Future<List<Purchase>> queryPurchasesByPseqList(List<int> pseqList) async {
  if (pseqList.isEmpty) return [];

  final db = await handler.initializeDB();
  final placeholders = List.filled(pseqList.length, '?').join(',');

  final maps = await db.rawQuery(
    'SELECT * FROM purchase WHERE pseq IN ($placeholders)',
    pseqList,
  );

  return maps.map((e) => Purchase.fromMap(e)).toList();
}
// ✅ (추가) 특정 상태(pstatus)들을 제외하고 유저 주문내역 조회

Future<List<Purchase>> queryPurchasesForUserExcludeStatus(
  String userId,
  List<int> excludeStatuses,
) async {
  final db = await handler.initializeDB();

  if (excludeStatuses.isEmpty) {
    return queryPurchasesForUser(userId);
  }

  final placeholders = List.filled(excludeStatuses.length, '?').join(',');
  final args = <dynamic>[userId, ...excludeStatuses];

  final maps = await db.rawQuery(
    'SELECT * FROM purchase WHERE userid = ? AND pstatus NOT IN ($placeholders) ORDER BY pseq DESC',
    args,
  );

  return maps.map((e) => Purchase.fromMap(e)).toList();
}
// ✅ 반품 요청된 주문(=refund에 존재하는 rpseq)은 주문내역에서 제외하고 가져오기
Future<List<Purchase>> queryPurchasesForUserExcludeRefunded(String userId) async {
  final db = await handler.initializeDB();

  final maps = await db.rawQuery(
    '''
    SELECT p.*
    FROM purchase p
    WHERE p.userid = ?
      AND NOT EXISTS (
        SELECT 1 FROM refund r
        WHERE r.rpseq = p.pseq
      )
    ORDER BY p.pseq DESC
    ''',
    [userId],
  );

  return maps.map((e) => Purchase.fromMap(e)).toList();
}

}
