import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/customer.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class CustomerDatabase {
  final handler = DatabaseHandler();

  // 검색
  Future<List<Customer>> queryCustomer() async{
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults = await db.rawQuery(
      'select * from customer'
    );
    return queryResults.map((e) => Customer.fromMap(e)).toList();
  }

  // 이메일 중복 체크
  Future<int> idCheck(String id) async {
    final db = await handler.initializeDB();
    var result = await db.rawQuery(
      """
      select count(*) as count
      from customer
      where cemail = ?
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
      select * from customer
      where cemail = ? and cpw = ?
      """,
      [id, pw]
    );
    return result.isNotEmpty;
  }

  // 입력
  Future<int> insertCustomer(Customer customer) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawInsert(
      """
        insert into customer
        (cemail, cpw, cphone, cname, caddress)
        values
        (?,?,?,?,?)
      """,
      [customer.cemail, customer.cpw, customer.cphone, customer.cname, customer.caddress]
    );
    return result;
  }

  // 수정
  Future<int> updateCustomer(Customer customer) async{
    int result = 0;
    final Database db = await handler.initializeDB();
    result = await db.rawUpdate(
      """
      update customer
      set cphone = ?, cname = ?, caddress = ?
      where cseq = ?
      """,
      [customer.cphone, customer.cname, customer.caddress]
    );
    return result;
  }

  // 삭제
  Future<void> deleteCustomer(int cseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from customer
        where cseq = ?
      """,
      [cseq]
    );
  }
  
}