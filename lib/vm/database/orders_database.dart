import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/orders.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class OrdersDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  Future<List<Orders>> queryOrders() async {
    final Database db = await handler.initializeDB();
    final maps = await db.query('orders', orderBy: 'oseq DESC');
    return maps.map((e) => Orders.fromMap(e)).toList();
  }

  Future<int> insertOrders(Orders orders) async {
    final Database db = await handler.initializeDB();
    return await db.rawInsert(
      '''
      INSERT INTO orders (ostatus, odate, oamount)
      VALUES (?,?,?)
      ''',
      [orders.ostatus, orders.odate, orders.oamount],
    );
  }

  Future<int> updateOrders(Orders orders) async {
    final Database db = await handler.initializeDB();
    return await db.rawUpdate(
      '''
      UPDATE orders
      SET ostatus = ?, odate = ?, oamount = ?
      WHERE oseq = ?
      ''',
      [orders.ostatus, orders.odate, orders.oamount, orders.oseq],
    );
  }

  Future<int> deleteOrders(int oseq) async {
    final Database db = await handler.initializeDB();
    return await db.rawDelete(
      'DELETE FROM orders WHERE oseq = ?',
      [oseq],
    );
  }
}
