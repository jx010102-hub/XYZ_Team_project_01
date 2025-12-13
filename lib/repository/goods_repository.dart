import 'dart:collection';
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

// 대표 상품 목록을 DB에서 읽어오는 전용 Repository (같은 데이터를 여러 화면에서 반복 조회하지 않도록)
class GoodsRepository {

  static List<Goods>? _repCache;          // Cache
  static Future<List<Goods>>? _repFuture; // Future

  // 대표 상품 목록 조회
  static Future<List<Goods>> getRepresentativeGoods() async {

    //이미 캐시가 있다면 DB 접근 없이 즉시 반환
    if (_repCache != null) {
      return UnmodifiableListView(_repCache!);
    }

    // Future가 없다면 새로 로딩 시작
    _repFuture ??= _loadRepresentativeGoods();

    // 로딩 완료까지 대기
    final result = await _repFuture!;

    // 외부에서 수정 못 하도록 읽기 전용 리스트로 반환
    return UnmodifiableListView(result);
  }

    // 실제 DB 접근
  static Future<List<Goods>> _loadRepresentativeGoods() async {
    final db = GoodsDatabase();

    // 대표 상품만 DB에서 조회
    final list = await db.queryRepresentativeGoods();

    // 캐시에 저장
    _repCache = list;

    // 로딩 완료 → Future 참조 제거
    _repFuture = null;

    return list;
  }

  // 캐시 초기화
  static void clearCache() {
    _repCache = null;
    _repFuture = null;
  }
}
