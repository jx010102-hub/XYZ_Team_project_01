import 'package:sqflite/sqflite.dart';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/database_handler.dart';

class GoodsDatabase {
  final DatabaseHandler handler = DatabaseHandler();

  // 공용 유틸
  Future<Database> _db() => handler.initializeDB();

  String _placeholders(int n) => List.filled(n, '?').join(',');

  Future<List<Goods>> _queryGoodsByGseqList({
    required List<int> gseqList,
    required String selectSql,
    bool emptyReturn = true,
  }) async {
    if (gseqList.isEmpty) return emptyReturn ? [] : [];
    final db = await _db();
    final maps = await db.rawQuery(selectSql, gseqList);
    return maps.map((e) => Goods.fromMap(e)).toList();
  }

  // Read

  // 빠른 검색 (대표 상품만)
  Future<List<Goods>> queryRepresentativeGoods() async {
    final db = await _db();
    final result = await db.rawQuery('''
      SELECT *
      FROM goods
      WHERE gseq IN (
        SELECT MIN(gseq)
        FROM goods
        GROUP BY gname
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
    final db = await _db();
    final result = await db.query(
      'goods',
      columns: ['gseq'],
      where: 'gname = ? AND gsize = ? AND gcolor = ?',
      whereArgs: [gname, gsize, gcolor],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // 이름으로 해당 상품의 모든 옵션 불러오기
  Future<List<Goods>> getGoodsByName(String gname) async {
    final db = await _db();
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
    final db = await _db();
    final result = await db.query(
      'goods',
      where: 'gname = ? AND gsize = ? AND gcolor = ?',
      whereArgs: [gname, gsize, gcolor],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Goods.fromMap(result.first);
  }

  /// GSEQ로 특정 상품 옵션 조회
  Future<Goods?> getGoodsByGseq(int gseq) async {
    final db = await _db();
    final maps = await db.query(
      'goods',
      where: 'gseq = ?',
      whereArgs: [gseq],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Goods.fromMap(maps.first);
  }
  
  /// 리스트용: mainimage만 포함(나머지 blob 제외) + 필요한 컬럼만 SELECT
  Future<List<Goods>> getGoodsThumbByGseqList(List<int> gseqList) async {
    if (gseqList.isEmpty) return [];
    final sql = '''
      SELECT 
        gseq, gsumamount, gname, gengname, gsize, gcolor, gcategory,
        manufacturer, price,
        mainimage
      FROM goods
      WHERE gseq IN (${_placeholders(gseqList.length)})
    ''';
    return _queryGoodsByGseqList(gseqList: gseqList, selectSql: sql);
  }

  // 입력 (manufacturer, price 포함)
  Future<int> insertGoods(Goods goods) async {
    final db = await _db();

    final isExists = await existsGoods(
      gname: goods.gname,
      gsize: goods.gsize,
      gcolor: goods.gcolor,
    );
    if (isExists) return 0;

    return db.rawInsert(
      '''
      INSERT INTO goods
      (gsumamount, gname, gengname, gsize, gcolor, gcategory, manufacturer, price,
       mainimage, topimage, backimage, sideimage)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
      ''',
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
  }

  // 수정 (manufacturer, price 포함)
  Future<int> updateGoods(Goods goods) async {
    if (goods.gseq == null) return 0;

    final db = await _db();
    return db.rawUpdate(
      '''
      UPDATE goods
      SET gsumamount = ?,
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
      WHERE gseq = ?
      ''',
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
  }

  // 삭제
  Future<void> deleteGoods(int gseq) async {
    final db = await _db();
    await db.rawDelete(
      'DELETE FROM goods WHERE gseq = ?',
      [gseq],
    );
  }

  // 재고(gsumamount) 업데이트
  Future<int> updateGoodsQuantity({
    required int gseq,
    required int quantityChange,
  }) async {
    final db = await _db();

    int result = 0;
    final query = await db.rawQuery(
      'SELECT gsumamount FROM goods WHERE gseq = ?',
      [gseq],
    );

    if (query.isNotEmpty) {
      final currentQty = query.first['gsumamount'] as int;
      var newQty = currentQty + quantityChange;

      if (newQty < 0) {
        newQty = 0;
        print("경고: 재고가 부족하여 0으로 설정되었습니다.");
      }

      result = await db.rawUpdate(
        'UPDATE goods SET gsumamount = ? WHERE gseq = ?',
        [newQty, gseq],
      );
    }
    return result;
  }
}
