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

  // 입력 (manufacturer, price 포함)
  Future<int> insertGoods(Goods goods) async {
    final Database db = await handler.initializeDB();

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
        goods.manufacturer,
        goods.price,
        goods.mainimage,
        goods.topimage,
        goods.backimage,
        goods.sideimage,
      ],
    );

    return result;
  }

  // 수정 (manufacturer, price 포함)
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

  // 이름으로 해당 상품의 모든 옵션 불러오기
  Future<List<Goods>> getGoodsByName(String gname) async {
    final Database db = await handler.initializeDB();
    final result = await db.query(
      'goods',
      where: 'gname = ?',
      whereArgs: [gname],
    );
    return result.map((e) => Goods.fromMap(e)).toList();
  }

  // 이름 + 사이즈 + 색상으로 특정 한 옵션만 불러오기
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

  // ⭐️⭐️⭐️ 1. 상품 재고(gsumamount)를 업데이트하는 함수 ⭐️⭐️⭐️
  Future<int> updateGoodsQuantity({
    required int gseq,
    required int quantityChange,
  }) async {
    int result = 0;
    final Database db = await handler.initializeDB();

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

      result = await db.rawUpdate(
        'update goods set gsumamount = ? where gseq = ?',
        [newQty, gseq],
      );
    }
    return result;
  }

  // ⭐️⭐️⭐️ 2. 주문 번호(pseq)를 통해 해당 주문 상품의 Goods ID(gseq)를 조회 (시나리오 2 적용) ⭐️⭐️⭐️
  // Purchase 테이블에 GSEQ가 직접 있다고 가정합니다.
  Future<int?> getGoodsIdByPurchaseId(int pseq) async {
    final db = await handler.initializeDB();
    
    // ⚠️⚠️ 'purchase' 테이블에 'gseq' 컬럼이 있어야 합니다.
    final List<Map<String, dynamic>> maps = await db.query(
      'purchase', 
      columns: ['gseq'],
      where: 'pseq = ?',
      whereArgs: [pseq],
      limit: 1, 
    );
    
    if (maps.isNotEmpty) {
      return maps.first['gseq'] as int?;
    } else {
      print('오류: purchase 테이블에서 pseq=$pseq의 gseq를 찾을 수 없습니다.');
      return null; 
    }
  }

  // ⭐️⭐️⭐️ 3. GSEQ를 사용하여 특정 상품 옵션의 모든 정보를 조회 ⭐️⭐️⭐️
  Future<Goods?> getGoodsByGseq(int gseq) async {
    final db = await handler.initializeDB();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'goods', 
      where: 'gseq = ?',
      whereArgs: [gseq],
      limit: 1, 
    );
    
    if (maps.isNotEmpty) {
      return Goods.fromMap(maps.first); 
    } else {
      return null;
    }
  }
}