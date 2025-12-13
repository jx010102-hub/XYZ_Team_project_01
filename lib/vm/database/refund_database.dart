import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class RefundDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  Future<int> insertRefund(Refund refund) async {
    final db = await handler.initializeDB();
    final refundMap = refund.toMap();
    refundMap.remove('rseq');

    // ✅ rpseq(주문번호) 중복 방지까지 DB에서 잡고 싶으면
    // refund 테이블에 UNIQUE(rpseq) 걸어두는게 제일 강함(아래 설명 참고)
    return await db.insert(
      'refund',
      refundMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// ✅ 유저 반품내역 (JOIN 제거 버전)
  /// - purchase.userid로 rpseq 후보를 뽑고, refund에서 IN으로 가져옴
  Future<List<Refund>> queryRefundsByUserId(String userId) async {
    final db = await handler.initializeDB();

    final maps = await db.rawQuery(
      '''
      SELECT r.*
      FROM refund r
      WHERE r.rpseq IN (
        SELECT p.pseq
        FROM purchase p
        WHERE p.userid = ?
      )
      ORDER BY r.rseq DESC
      ''',
      [userId],
    );

    return maps.map((e) => Refund.fromMap(e)).toList();
  }

  // ✅ 관리자: 반품 승인 대기 목록 (rstatus=1)
  Future<List<Refund>> queryPendingRefunds() async {
    final db = await handler.initializeDB();
    final maps = await db.query(
      'refund',
      where: 'rstatus = ?',
      whereArgs: [1],
      orderBy: 'rseq DESC',
    );
    return maps.map((e) => Refund.fromMap(e)).toList();
  }

  // ✅ 관리자: 반품 승인 완료 처리 (rstatus=2) - 대기(1)인 것만 승인
  Future<int> approveRefund(int rseq) async {
    final db = await handler.initializeDB();
    return await db.update(
      'refund',
      {'rstatus': 2},
      where: 'rseq = ? AND rstatus = ?',
      whereArgs: [rseq, 1],
    );
  }

  // ✅ 고객: 반품 최종 완료 처리 (rstatus=3)
  Future<int> completeRefund(int rseq) async {
    final db = await handler.initializeDB();
    return await db.update(
      'refund',
      {'rstatus': 3},
      where: 'rseq = ?',
      whereArgs: [rseq],
    );
  }

  // ✅ 주문(pseq) 기준 반품 존재 여부 체크
  Future<bool> existsRefundByPseq(int pseq) async {
    final db = await handler.initializeDB();
    final maps = await db.query(
      'refund',
      columns: ['rseq'], // ✅ 꼭 필요한 컬럼만
      where: 'rpseq = ?',
      whereArgs: [pseq],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // ✅ 트랜잭션: 반품완료(rstatus=3) + 재고복원(+restoreQty)
  Future<bool> completeRefundWithStockRestore({
    required int rseq,
    required int gseq,
    required int restoreQty,
  }) async {
    final db = await handler.initializeDB();

    try {
      return await db.transaction((txn) async {
        final r1 = await txn.update(
          'refund',
          {'rstatus': 3},
          where: 'rseq = ? AND rstatus = ?',
          whereArgs: [rseq, 2],
        );

        if (r1 <= 0) return false;

        final r2 = await txn.rawUpdate(
          'UPDATE goods SET gsumamount = gsumamount + ? WHERE gseq = ?',
          [restoreQty, gseq],
        );

        if (r2 <= 0) {
          throw Exception('goods stock restore failed');
        }

        return true;
      });
    } catch (_) {
      return false;
    }
  }

  /// ✅ 유저가 반품요청한 주문번호 Set (주문내역 숨김용)
  /// JOIN 대신 IN 서브쿼리로도 가능
  Future<Set<int>> queryRefundedPurchaseSeqSetByUserId(String userId) async {
    final db = await handler.initializeDB();

    final maps = await db.rawQuery(
      '''
      SELECT r.rpseq
      FROM refund r
      WHERE r.rpseq IN (
        SELECT p.pseq FROM purchase p WHERE p.userid = ?
      )
      ''',
      [userId],
    );

    return maps
        .map((e) => e['rpseq'])
        .where((v) => v != null)
        .map((v) => v as int)
        .toSet();
  }
}
