// lib/vm/database/basket_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/basket.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class BasketDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  Future<Database> _db() => handler.initializeDB();

  // 유저 장바구니 조회
  Future<List<Basket>> queryBasketByUser(String userId) async {
    final db = await _db();
    final maps = await db.query(
      'basket',
      where: 'userid = ?',
      whereArgs: [userId],
      orderBy: 'bseq DESC',
    );
    return maps.map(Basket.fromMap).toList();
  }

  // upsert: 같은 옵션이면 qty 누적, 없으면 insert
  Future<int> upsertBasket({
    required String userid,
    required String gname,
    required String gsize,
    required String gcolor,
    required int qty,
  }) async {
    final db = await _db();

    // 기존 데이터 조회
    final exist = await db.query(
      'basket',
      columns: ['bseq', 'qty'],
      where: 'userid = ? AND gname = ? AND gsize = ? AND gcolor = ?',
      whereArgs: [userid, gname, gsize, gcolor],
      limit: 1,
    );

    // 있으면 qty 누적 update
    if (exist.isNotEmpty) {
      final bseq = exist.first['bseq'] as int;
      final oldQty = (exist.first['qty'] as int?) ?? 0;
      final newQty = oldQty + qty;

      return db.update(
        'basket',
        {'qty': newQty},
        where: 'bseq = ?',
        whereArgs: [bseq],
      );
    }

    // 없으면 insert
    return db.insert(
      'basket',
      {
        'userid': userid,
        'gname': gname,
        'gsize': gsize,
        'gcolor': gcolor,
        'qty': qty,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // 수량 변경
  Future<int> updateBasketQty(int bseq, int newQty) async {
    final db = await _db();
    return db.update(
      'basket',
      {'qty': newQty},
      where: 'bseq = ?',
      whereArgs: [bseq],
    );
  }

  // 옵션 변경
  Future<int> updateBasketOption({
    required int bseq,
    required String gsize,
    required String gcolor,
  }) async {
    final db = await _db();
    return db.update(
      'basket',
      {'gsize': gsize, 'gcolor': gcolor},
      where: 'bseq = ?',
      whereArgs: [bseq],
    );
  }

  // 단건 삭제
  Future<int> deleteBasket(int bseq) async {
    final db = await _db();
    return db.delete(
      'basket',
      where: 'bseq = ?',
      whereArgs: [bseq],
    );
  }

  // 결제 성공한 것만 장바구니에서 제거
  Future<int> deleteBasketByBseqList(List<int> bseqList) async {
    if (bseqList.isEmpty) return 0;

    final db = await _db();
    final placeholders = List.filled(bseqList.length, '?').join(',');

    return db.delete(
      'basket',
      where: 'bseq IN ($placeholders)',
      whereArgs: bseqList,
    );
  }
}
