import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/supplier.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class SupplierDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  // 검색
  Future<List<Supplier>> querySupplier() async {
    final Database db = await handler.initializeDB();
    final maps = await db.query('supplier', orderBy: 'sid ASC');
    return maps.map((e) => Supplier.fromMap(e)).toList();
  }

  // 로그인
  // ✅ supplier.sid가 INTEGER 이므로 id를 int로 파싱 시도 (실패 시 false)
  Future<bool> loginCheck(String id, String name) async {
    final Database db = await handler.initializeDB();

    final int? sid = int.tryParse(id.trim());
    if (sid == null) return false;

    final result = await db.query(
      'supplier',
      where: 'sid = ? AND sname = ?',
      whereArgs: [sid, name.trim()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // 입력
  Future<int> insertSupplier(Supplier supplier) async {
    final Database db = await handler.initializeDB();
    return await db.rawInsert(
      '''
      INSERT INTO supplier (sid, sname)
      VALUES (?, ?)
      ''',
      [supplier.sid, supplier.sname],
    );
  }

  // 수정
  Future<int> updateSupplier(Supplier supplier) async {
    final Database db = await handler.initializeDB();
    return await db.rawUpdate(
      '''
      UPDATE supplier
      SET sname = ?
      WHERE sid = ?
      ''',
      [supplier.sname, supplier.sid], // ✅ 누락된 sid 추가 (에러 방지)
    );
  }

  // 삭제
  Future<int> deleteSupplier(int sid) async {
    final Database db = await handler.initializeDB();
    return await db.rawDelete(
      'DELETE FROM supplier WHERE sid = ?',
      [sid],
    );
  }
}
