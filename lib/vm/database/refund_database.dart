import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/refund.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class RefundDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Refund>> queryRefund() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from refund'
    );
    return queryResults.map((e) => Refund.fromMap(e)).toList();
  }

  // 입력
  Future<int> insertRefund(Refund refund) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into refund
        (rdate, rreason, rstatus, rpseq)
        values
        (?,?,?,?)
      """,
      [refund.rdate, refund.rreason, refund.rstatus, refund.rpseq]
    );
    return result;
  }

  // 수정
  Future<int> updateRefund(Refund refund) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update refund
      set rstatus
      where rseq = ?
      """,
      [refund.rstatus, refund.rseq]
    );
    return result;
  }

  // 삭제
  Future<void> deleteRefund(int rseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from refund
        where rseq = ?
      """,
      [rseq]
    );
  }
}