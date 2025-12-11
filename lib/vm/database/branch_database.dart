import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/branch.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class BranchDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Branch>> queryBranch() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from branch'
    );
    return queryResults.map((e) => Branch.fromMap(e)).toList();
  }

  // 입력
  Future<int> insertBranch(Branch branch) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into branch
        (bid, blat, blng, bname)
        values
        (?,?,?,?)
      """,
      [branch.bid, branch.blat, branch.blng, branch.bname]
    );
    return result;
  }

  // 수정
  Future<int> updateBranch(Branch branch) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update branch
      set blat = ?, blng = ?, bname = ?
      where bid = ?
      """,
      [branch.blat, branch.blng, branch.bname, branch.bid]
    );
    return result;
  }

  // 삭제
  Future<void> deleteBranch(int bid) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from branch
        where bid = ?
      """,
      [bid]
    );
  }
}