import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/supply_order.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class SupplyOrderDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  Future<int> insertOrder(SupplyOrder order) async {
    final Database db = await handler.initializeDB();
    return await db.rawInsert(
      '''
      INSERT INTO supply_order
      (manufacturer, requester, gseq, gname, gsize, gcolor, qty, status, reqdate, apprdate)
      VALUES (?,?,?,?,?,?,?,?,?,?)
      ''',
      [
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
      ],
    );
  }

  // 제조사별 대기(0) 발주 조회
  Future<List<SupplyOrder>> queryPendingByManufacturer(String manufacturer) async {
    final Database db = await handler.initializeDB();
    final result = await db.query(
      'supply_order',
      where: 'manufacturer = ? AND status = ?',
      whereArgs: [manufacturer, 0],
      orderBy: 'oseq DESC',
    );
    return result.map((e) => SupplyOrder.fromMap(e)).toList();
  }

  // 승인 + 재고 반영
  Future<int> approveOrderAndAddStock({
    required int oseq,
    required int gseq,
    required int qty,
    required String apprdate,
  }) async {
    final Database db = await handler.initializeDB();

    return await db.transaction<int>((txn) async {
      // 1) 발주 승인 처리
      final int a = await txn.rawUpdate(
        '''
        UPDATE supply_order
        SET status = 1, apprdate = ?
        WHERE oseq = ?
        ''',
        [apprdate, oseq],
      );

      if (a <= 0) return 0;

      // 2) 재고 반영 (성공 여부 체크)
      final int b = await txn.rawUpdate(
        '''
        UPDATE goods
        SET gsumamount = gsumamount + ?
        WHERE gseq = ?
        ''',
        [qty, gseq],
      );

      if (b <= 0) {
        // goods가 없거나 업데이트 실패면 롤백 유도
        throw Exception('goods stock update failed (gseq=$gseq)');
      }

      return a;
    });
  }

}