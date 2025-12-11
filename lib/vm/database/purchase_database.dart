import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/purchase.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class PurchaseDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Purchase>> queryPurchase() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from purchase'
    );
    return queryResults.map((e) => Purchase.fromMap(e)).toList();
  }

  // 입력
  Future<int> insertPurchase(Purchase purchase) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into purchase
        (pstatus, pdate, pamount, ppaydate, ppayprice, ppayway, ppayamount, pdiscount, userid)
        values
        (?,?,?,?,?,?,?,?,?)
      """,
      [
        purchase.pstatus, purchase.pdate,
        purchase.pamount, purchase.ppaydate,
        purchase.ppayprice, purchase.ppayway,
        purchase.ppayamount, purchase.pdiscount, purchase.userid
      ]
    );
    return result;
  }

  // 수정
  Future<int> updatePurchase(Purchase purchase) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update purchase
      set pstatus = ?, pamount = ?, ppaydate = ?, ppayprice = ?, ppayway = ?, ppayamount = ?
      where pseq = ?
      """,
      [
        purchase.pstatus,
        purchase.pamount, purchase.ppaydate,
        purchase.ppayprice, purchase.ppayway,
        purchase.ppayamount, purchase.pseq
      ]
    );
    return result;
  }

  // 삭제
  Future<void> deletePurchase(int pseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from purchase
        where pseq = ?
      """,
      [pseq]
    );
  }
}