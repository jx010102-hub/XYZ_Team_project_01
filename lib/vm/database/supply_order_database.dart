import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/supply_order.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class SupplyOrderDatabase {
  final handler = DatabaseHandler();

  Future<int> insertOrder(SupplyOrder order) async {
    final Database db = await handler.initializeDB();
    final int result = await db.rawInsert("""
      insert into supply_order
      (manufacturer, requester, gseq, gname, gsize, gcolor, qty, status, reqdate, apprdate)
      values (?,?,?,?,?,?,?,?,?,?)
    """, [
      order.manufacturer,
      order.requester,
      order.gseq,
      order.gname,
      order.gsize,
      order.gcolor,
      order.qty,
      order.status,
      order.reqdate,
      order.apprdate,
    ]);
    return result;
  }

  Future<List<SupplyOrder>> queryPendingByManufacturer(String manufacturer) async {
    final Database db = await handler.initializeDB();
    final result = await db.query(
      'supply_order',
      where: 'manufacturer = ? and status = ?',
      whereArgs: [manufacturer, 0],
      orderBy: 'oseq desc',
    );
    return result.map((e) => SupplyOrder.fromMap(e)).toList();
  }

  // ✅ 승인 + 재고 반영 (트랜잭션)
  Future<int> approveOrderAndAddStock({
    required int oseq,
    required int gseq,
    required int qty,
    required String apprdate,
  }) async {
    final Database db = await handler.initializeDB();

    return await db.transaction<int>((txn) async {
      // 1) 발주 승인 처리
      final int a = await txn.rawUpdate("""
        update supply_order
        set status = 1, apprdate = ?
        where oseq = ?
      """, [apprdate, oseq]);

      if (a <= 0) return 0;

      // 2) 재고 반영
      await txn.rawUpdate("""
        update goods
        set gsumamount = gsumamount + ?
        where gseq = ?
      """, [qty, gseq]);

      return a;
    });
  }

  // 기존 approveOrder는 남겨도 됨
  Future<int> approveOrder(int oseq, String apprdate) async {
    final Database db = await handler.initializeDB();
    return db.rawUpdate("""
      update supply_order
      set status = 1, apprdate = ?
      where oseq = ?
    """, [apprdate, oseq]);
  }
}
