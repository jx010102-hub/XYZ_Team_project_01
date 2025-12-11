// import 'package:sqflite/sqflite.dart';
// import 'package:xyz_project_01/model/approval.dart';
// import 'package:xyz_project_01/vm/database/database_handler.dart';

// class ApprovalDatabase {
//   final handler = DatabaseHandler();

//   Future<List<Approval>> queryTodolist() async{
//     final Database db = await initializeDB();
//     final List<Map<String, Object?>> queryResults = await db.rawQuery(
//       'select * from todolist'
//     );
//     return queryResults.map((e) => TodoList.fromMap(e)).toList();
//   }

// }