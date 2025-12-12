// lib/repository/goods_repository.dart
import 'package:xyz_project_01/model/goods.dart';
import 'package:xyz_project_01/vm/database/goods_database.dart';

class GoodsRepository {
  static List<Goods>? _repCache;

  static Future<List<Goods>> getRepresentativeGoods() async {
    if (_repCache != null) return _repCache!;
    final db = GoodsDatabase();
    _repCache = await db.queryRepresentativeGoods();
    return _repCache!;
  }

  static void clearCache() {
    _repCache = null;
  }
}
