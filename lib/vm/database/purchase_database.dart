import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class PurchaseDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  // ===============================
  // Create
  // ===============================
  Future<int> insertPurchase(Purchase purchase) async {
    final db = await handler.initializeDB();

    final map = purchase.toMap();
    map.remove('pseq'); // AUTOINCREMENT

    return db.insert(
      'purchase',
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ===============================
  // Read
  // ===============================

  /// 유저 구매내역 조회 (옵션: status로 필터)
  Future<List<Purchase>> queryPurchasesForUser(
    String userId, {
    int? status,
  }) async {
    final db = await handler.initializeDB();

    final args = <dynamic>[userId];
    var sql = "SELECT * FROM purchase WHERE userid = ?";

    if (status != null) {
      sql += " AND pstatus = ?";
      args.add(status);
    }

    sql += " ORDER BY pseq DESC";

    final maps = await db.rawQuery(sql, args);
    return maps.map(Purchase.fromMap).toList();
  }

  /// 기존 코드 호환용(중복) - 내부 위임
  Future<List<Purchase>> queryPurchaseByUserId(String userId) async {
    return queryPurchasesForUser(userId);
  }

  /// pseq 단건 조회 (refund.rpseq -> purchase 매핑용)
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

  /// pseq 리스트 조회 (IN)
  Future<List<Purchase>> queryPurchasesByPseqList(List<int> pseqList) async {
    if (pseqList.isEmpty) return [];

    final db = await handler.initializeDB();
    final placeholders = List.filled(pseqList.length, '?').join(',');

    final maps = await db.rawQuery(
      'SELECT * FROM purchase WHERE pseq IN ($placeholders)',
      pseqList,
    );

    return maps.map(Purchase.fromMap).toList();
  }

  /// 특정 상태들을 제외하고 유저 주문내역 조회
  Future<List<Purchase>> queryPurchasesForUserExcludeStatus(
    String userId,
    List<int> excludeStatuses,
  ) async {
    if (excludeStatuses.isEmpty) {
      return queryPurchasesForUser(userId);
    }

    final db = await handler.initializeDB();
    final placeholders = List.filled(excludeStatuses.length, '?').join(',');
    final args = <dynamic>[userId, ...excludeStatuses];

    final maps = await db.rawQuery(
      'SELECT * FROM purchase '
      'WHERE userid = ? AND pstatus NOT IN ($placeholders) '
      'ORDER BY pseq DESC',
      args,
    );

    return maps.map(Purchase.fromMap).toList();
  }

  /// 반품 요청된 주문(=refund에 존재하는 rpseq)은 주문내역에서 제외
  Future<List<Purchase>> queryPurchasesForUserExcludeRefunded(String userId) async {
    final db = await handler.initializeDB();

    final maps = await db.rawQuery(
      '''
      SELECT p.*
      FROM purchase p
      WHERE p.userid = ?
        AND NOT EXISTS (
          SELECT 1
          FROM refund r
          WHERE r.rpseq = p.pseq
        )
      ORDER BY p.pseq DESC
      ''',
      [userId],
    );

    return maps.map(Purchase.fromMap).toList();
  }

  /// 승인 대기 목록(pstatus=2)
  Future<List<Purchase>> queryPendingPurchases() async {
    final db = await handler.initializeDB();

    final maps = await db.query(
      'purchase',
      where: 'pstatus = ?',
      whereArgs: [2],
      orderBy: 'pdate DESC',
    );

    return maps.map(Purchase.fromMap).toList();
  }

  // ===============================
  // Update
  // ===============================
  Future<int> updatePurchaseStatus(int pseq, int newStatus) async {
    final db = await handler.initializeDB();

    return db.update(
      'purchase',
      {'pstatus': newStatus},
      where: 'pseq = ?',
      whereArgs: [pseq],
    );
  }

  /// 승인 처리: 3으로 변경
  Future<int> updatePurchaseToApproved(int pseq) async {
    return updatePurchaseStatus(pseq, 3);
  }

  /// 수령 완료: 4로 변경
  Future<int> updatePurchaseToReceived(int pseq) async {
    return updatePurchaseStatus(pseq, 4);
  }
}
