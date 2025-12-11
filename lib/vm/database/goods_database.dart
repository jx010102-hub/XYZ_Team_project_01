import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class GoodsDatabase {
  final handler = DatabaseHandler();

  // 전체 검색
  Future<List<Goods>> queryGoods() async {
    final Database db = await handler.initializeDB();
    final List<Map<String, Object?>> queryResults =
        await db.rawQuery('select * from goods');
    return queryResults.map((e) => Goods.fromMap(e)).toList();
  }

  // 중복 체크
  Future<bool> existsGoods({
    required String gname,
    required String gsize,
    required String gcolor,
  }) async {
    final Database db = await handler.initializeDB();
    final result = await db.query(
      'goods',
      where: 'gname = ? and gsize = ? and gcolor = ?',
      whereArgs: [gname, gsize, gcolor],
    );
    return result.isNotEmpty;
  }

  // 입력
  Future<int> insertGoods(Goods goods) async {
    final Database db = await handler.initializeDB();

    // 중복 체크
    final bool isExists = await existsGoods(
      gname: goods.gname,
      gsize: goods.gsize,
      gcolor: goods.gcolor,
    );

    if (isExists) {
      return 0;
    }

    final int result = await db.rawInsert(
      """
        insert into goods
        (gsumamount, gname, gengname, gsize, gcolor, gcategory, mainimage, topimage, backimage, sideimage)
        values
        (?,?,?,?,?,?,?,?,?,?)
      """,
      [
        goods.gsumamount,
        goods.gname,
        goods.gengname,
        goods.gsize,
        goods.gcolor,
        goods.gcategory,
        goods.mainimage,
        goods.topimage,
        goods.backimage,
        goods.sideimage,
      ],
    );
    return result;
  }

  // 수정
  Future<int> updateGoods(Goods goods) async {
    if (goods.gseq == null) {
      return 0;
    }

    final Database db = await handler.initializeDB();

    final int result = await db.rawUpdate(
      """
      update goods
      set gsumamount = ?, 
          gname = ?, 
          gengname = ?, 
          gsize = ?, 
          gcolor = ?, 
          gcategory = ?,
          mainimage = ?,
          topimage = ?,
          backimage = ?,
          sideimage = ?
      where gseq = ?
      """,
      [
        goods.gsumamount,
        goods.gname,
        goods.gengname,
        goods.gsize,
        goods.gcolor,
        goods.gcategory,
        goods.mainimage,
        goods.topimage,
        goods.backimage,
        goods.sideimage,
        goods.gseq,
      ],
    );
    return result;
  }

  // 삭제
  Future<void> deleteGoods(int gseq) async{
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from goods
        where gseq = ?
      """,
      [gseq]
    );
  }

  // ----- 이름으로 해당 상품의 모든 옵션(사이즈+색상) 불러오기 -----
  Future<List<Goods>> getGoodsByName(String gname) async {
    final Database db = await handler.initializeDB();
    final result = await db.query(
      'goods',
      where: 'gname = ?',
      whereArgs: [gname],
    );
    return result.map((e) => Goods.fromMap(e)).toList();
  }

  // ----- 이름 + 사이즈 + 색상으로 특정 한 옵션만 불러오기 -----
  Future<Goods?> getGoodsVariant({
    required String gname,
    required String gsize,
    required String gcolor,
  }) async {
    final Database db = await handler.initializeDB();
    final result = await db.query(
      'goods',
      where: 'gname = ? and gsize = ? and gcolor = ?',
      whereArgs: [gname, gsize, gcolor],
    );

    if (result.isEmpty) return null;
    return Goods.fromMap(result.first);
  }
}
