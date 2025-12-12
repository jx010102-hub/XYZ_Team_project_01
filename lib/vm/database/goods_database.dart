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

  // 빠른 검색 (대표 상품만)
  Future<List<Goods>> queryRepresentativeGoods() async {
    final Database db = await handler.initializeDB();
    final result = await db.rawQuery('''
      select *
      from goods
      where gseq in (
        select min(gseq)
        from goods
        group by gname
      )
    ''');
    return result.map((e) => Goods.fromMap(e)).toList();
  }

  // 중복 체크
  // ✅ 기존 기준 유지: (gname + gsize + gcolor)
  // - manufacturer/price는 옵션 중복 기준에 보통 안 넣음
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

    // ✅ manufacturer, price 컬럼 추가
    final int result = await db.rawInsert(
      """
        insert into goods
        (gsumamount, gname, gengname, gsize, gcolor, gcategory, manufacturer, price, mainimage, topimage, backimage, sideimage)
        values
        (?,?,?,?,?,?,?,?,?,?,?,?)
      """,
      [
        goods.gsumamount,
        goods.gname,
        goods.gengname,
        goods.gsize,
        goods.gcolor,
        goods.gcategory,
        goods.manufacturer, // ✅ 추가
        goods.price,        // ✅ 추가 (double)
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

    // ✅ manufacturer, price 업데이트 포함
    final int result = await db.rawUpdate(
      """
        update goods
        set gsumamount = ?, 
            gname = ?, 
            gengname = ?, 
            gsize = ?, 
            gcolor = ?, 
            gcategory = ?,
            manufacturer = ?,
            price = ?,
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
        goods.manufacturer,
        goods.price,
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
  Future<void> deleteGoods(int gseq) async {
    final Database db = await handler.initializeDB();
    await db.rawUpdate(
      """
        delete from goods
        where gseq = ?
      """,
      [gseq],
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

  // ⭐️⭐️⭐️ 총 재고량(gsumamount)을 증감하는 함수 ⭐️⭐️⭐️
  Future<int> updateGoodsQuantity({
    required int gseq,
    required int quantityChange,
  }) async {
    int result = 0;
    final Database db = await handler.initializeDB();

    // 현재 재고 가져오기 (gsumamount)
    final List<Map<String, Object?>> query = await db.rawQuery(
      'select gsumamount from goods where gseq = ?',
      [gseq],
    );

    if (query.isNotEmpty) {
      int currentQty = query.first['gsumamount'] as int;
      int newQty = currentQty + quantityChange;

      if (newQty < 0) {
        newQty = 0;
        print("경고: 재고가 부족하여 0으로 설정되었습니다.");
      }

      // gsumamount 업데이트
      result = await db.rawUpdate(
        'update goods set gsumamount = ? where gseq = ?',
        [newQty, gseq],
      );
    }
    return result;
  }
}
