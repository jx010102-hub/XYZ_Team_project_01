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

  // 입력
  Future<int> insertEmployee(Employee employee) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into employee
        (eemail, epw, ephone, erank, erole, epower, workplace, ebid)
        values
        (?,?,?,?,?,?,?,?)
      """,
      [employee.eemail, employee.epw, employee.ephone, employee.erank, employee.erole, employee.epower, employee.workplace, employee.ebid]
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
      set epw = ?, ephone = ?
      where eseq = ?
      """,
      [employee.epw, employee.ephone, employee.eseq]
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