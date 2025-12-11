import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/employee.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class EmployeeDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Employee>> queryEmployee() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from employee'
    );
    return queryResults.map((e) => Employee.fromMap(e)).toList();
  }

  // 이메일 중복 체크
  Future<int> idCheck(String id) async {
    final db = await handler.initializeDB();
    var result = await db.rawQuery(
      """
      select count(*) as count
      from employee
      where eemail = ?
      """,
      [id],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 로그인
  Future<bool> loginCheck(String id, String pw) async {
    final Database db = await handler.initializeDB();
    final List<Map<String, dynamic>> result = await db.rawQuery(
      """
      select * from employee
      where eemail = ? and epw = ?
      """,
      [id, pw]
    );
    return result.isNotEmpty;
  }

  // 입력
  Future<int> insertEmployee(Employee employee) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into employee
        (eemail, epw, ename, ephone, erank, erole, epower, workplace, ebid)
        values
        (?,?,?,?,?,?,?,?,?)
      """,
      [employee.eemail, employee.epw, employee.ename, employee.ephone, employee.erank, employee.erole, employee.epower, employee.workplace, employee.ebid]
    );
    return result;
  }

  // 수정
  Future<int> updateEmployee(Employee employee) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update employee
      set epw = ?, ename = ?, ephone = ?
      where eseq = ?
      """,
      [employee.epw, employee.ename, employee.ephone, employee.eseq]
    );
    return result;
  }

  // 삭제
  Future<void> deleteEmployee(int eseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from employee
        where eseq = ?
      """,
      [eseq]
    );
  }

  
}