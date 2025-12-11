import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/branch.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class BranchDatabase {
  final handler = DatabaseHandler();

  // -----------------------------------------------------------------
  // ⭐️ 최초 1회만 데이터 삽입하는 로직으로 변경
  // -----------------------------------------------------------------
  Future<void> initializeBranchesIfEmpty(List<Branch> branches) async {
    final Database db = await handler.initializeDB();
    
    // 1. 현재 'branch' 테이블에 데이터 개수 확인
    final countResult = await db.rawQuery('SELECT COUNT(*) FROM branch');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    
    // 2. 데이터가 0개일 경우에만 삽입 진행
    if (count == 0) {
      await db.transaction((txn) async {
        for (var branch in branches) {
          await txn.rawInsert(
            """
            insert into branch
            (bid, blat, blng, bname)
            values
            (?,?,?,?)
            """,
            [branch.bid, branch.blat, branch.blng, branch.bname]
          );
        }
      });
      print('✅ DB의 branch 테이블에 ${branches.length}개의 매장 데이터가 초기 등록되었습니다.');
    } else {
      print('ℹ️ DB의 branch 테이블에 이미 데이터가 존재하여 초기 등록을 건너뜁니다 (현재 ${count}개).');
    }
  }

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