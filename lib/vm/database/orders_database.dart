import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/orders.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class OrdersDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Orders>> queryOrders() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from orders'
    );
    return queryResults.map((e) => Orders.fromMap(e)).toList();
  }

  // 입력
  Future<int> insertOrders(Orders orders) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into orders
        (ostatus, odate, oamount)
        values
        (?,?,?)
      """,
      [orders.ostatus, orders.odate, orders.oamount]
    );
    return result;
  }

  // 수정
  Future<int> updateOrders(Orders orders) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update orders
      set ostatus = ?, odate = ?, oamount = ?
      where oseq = ?
      """,
      [orders.ostatus, orders.odate, orders.oamount, orders.oseq]
    );
    return result;
  }

  // 삭제
  Future<void> deleteOrders(int oseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from orders
        where oseq = ?
      """,
      [oseq]
    );
  }
}