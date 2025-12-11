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
  
  // -----------------------------------------------------------------
  // ⭐️ 새로운 기능: 전체 매장 목록을 DB에 한 번에 등록 (자동 구현)
  // -----------------------------------------------------------------
  
  Future<void> insertAllBranches(List<Branch> branches) async {
    final Database db = await handler.initializeDB();
    
    // 데이터 중복 등록을 방지하기 위해, 먼저 테이블을 비우거나 (DROP/DELETE)
    // 혹은 각 항목이 없으면 삽입하는 로직을 사용해야 합니다.
    // 여기서는 간단하게 기존 데이터를 전부 삭제하고 새로 넣겠습니다.
    // 실제 운영 환경에서는 'upsert' 로직을 사용해야 합니다.
    
    await db.rawDelete('delete from branch'); // 모든 기존 데이터 삭제
    
    await db.transaction((txn) async {
      for (var branch in branches) {
        // 이미 DB에 insertBranch 함수가 있으므로 이를 활용합니다.
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
    print('✅ DB에 총 ${branches.length}개의 매장 데이터가 성공적으로 등록되었습니다.');
  }

  // -----------------------------------------------------------------

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