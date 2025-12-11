import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/supplier.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class SupplierDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Supplier>> querySupplier() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from supplier'
    );
    return queryResults.map((e) => Supplier.fromMap(e)).toList();
  }

  // 입력
  Future<int> insertSupplier(Supplier supplier) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into supplier
        (sid, sname)
        values
        (?,?)
      """,
      [supplier.sid, supplier.sname]
    );
    return result;
  }

  // 수정
  Future<int> updateSupplier(Supplier supplier) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update supplier
      set sname = ?
      where sid = ?
      """,
      [supplier.sname]
    );
    return result;
  }

  // 삭제
  Future<void> deleteSupplier(int sid) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from supplier
        where sid = ?
      """,
      [sid]
    );
  }

  
}