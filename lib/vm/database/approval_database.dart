import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/approval.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class ApprovalDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Approval>> queryApproval() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from approval'
    );
    return queryResults.map((e) => Approval.fromMap(e)).toList();
  }

  // 입력
  Future<int> insertApproval(Approval approval) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into approval
        (astatus, adate, aoseq)
        values
        (?,?,?)
      """,
      [approval.astatus, approval.adate, approval.aoseq]
    );
    return result;
  }

  // 수정
  Future<int> updateApproval(Approval approval) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update approval
      set astatus = ?, adate = ?, aoseq = ?
      where aseq = ?
      """,
      [approval.astatus, approval.adate, approval.aoseq, approval.aseq]
    );
    return result;
  }

  // 삭제
  Future<void> deleteApproval(int aseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from approval
        where aseq = ?
      """,
      [aseq]
    );
  }

}