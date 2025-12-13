// lib/vm/database/seed_data.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:xyz_project_01/vm/database/database_handler.dart';
import 'package:xyz_project_01/vm/database/example_data.dart';

class SeedData {
  final DatabaseHandler handler = DatabaseHandler();

  Future<Uint8List?> _loadImageOrNull(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      // 이미지 로드 실패 시 로그
      // (앱 동작 영향 없게 null 반환)
      print('❌ [SeedData Error] 이미지 로드 실패: $path, 오류: $e');
      return null;
    }
  }

  Future<void> insertExampleData() async {
    final db = await handler.initializeDB();
    int insertCount = 0;

    // 같은 gname에 대한 이미지 로딩 최적화(기존 유지)
    final Map<String, Uint8List?> loadedImages = {};

    print('======================================================');
    print('[SeedData] 데이터베이스 초기화(Seed) 시작');

    // ✅ 전체를 트랜잭션으로 묶어서 "반쪽 삽입" 방지
    await db.transaction((txn) async {
      // 1) customer (기준: cemail)
      for (final row in ExampleData.customers) {
        final exists = await txn.query(
          "customer",
          where: "cemail = ?",
          whereArgs: [row['cemail']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("customer", row);
        }
      }

      // 3) branch (기준: bid)
      for (final row in ExampleData.branches) {
        final exists = await txn.query(
          "branch",
          where: "bid = ?",
          whereArgs: [row['bid']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("branch", row);
        }
      }

      // 4) employee (기준: eemail)
      for (final row in ExampleData.employees) {
        final exists = await txn.query(
          "employee",
          where: "eemail = ?",
          whereArgs: [row['eemail']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("employee", row);
        }
      }

      // 5) supplier (기준: sid)
      for (final row in ExampleData.suppliers) {
        final exists = await txn.query(
          "supplier",
          where: "sid = ?",
          whereArgs: [row['sid']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("supplier", row);
        }
      }

      // 2) goods 데이터 삽입 (이미지 포함)
      for (final row in ExampleData.goods) {
        final gname = row['gname'];
        final gsize = row['gsize'];
        final gcolor = row['gcolor'];

        final exists = await txn.query(
          "goods",
          where: "gname = ? AND gsize = ? AND gcolor = ?",
          whereArgs: [gname, gsize, gcolor],
          limit: 1,
        );

        if (exists.isNotEmpty) continue;

        Uint8List? mainImage;
        Uint8List? topImage;
        Uint8List? backImage;
        Uint8List? sideImage;

        // 캐싱(기존 로직 유지)
        final cacheMainKey = '${gname}_main';
        final cacheTopKey = '${gname}_top';
        final cacheBackKey = '${gname}_back';
        final cacheSideKey = '${gname}_side';

        if (!loadedImages.containsKey(cacheMainKey)) {
          mainImage = await _loadImageOrNull(row['mainimagePath'] as String?);
          topImage = await _loadImageOrNull(row['topimagePath'] as String?);
          backImage = await _loadImageOrNull(row['backimagePath'] as String?);
          sideImage = await _loadImageOrNull(row['sideimagePath'] as String?);

          loadedImages[cacheMainKey] = mainImage;
          loadedImages[cacheTopKey] = topImage;
          loadedImages[cacheBackKey] = backImage;
          loadedImages[cacheSideKey] = sideImage;
        } else {
          mainImage = loadedImages[cacheMainKey];
          topImage = loadedImages[cacheTopKey];
          backImage = loadedImages[cacheBackKey];
          sideImage = loadedImages[cacheSideKey];
        }

        // ✅ goods 테이블 컬럼 맞추기: manufacturer, price 포함
        // ExampleData에 없을 수도 있으니 안전 기본값 처리
        final insertData = <String, dynamic>{
          'gsumamount': row['gsumamount'],
          'gname': gname,
          'gengname': row['gengname'],
          'gsize': gsize,
          'gcolor': gcolor,
          'gcategory': row['gcategory'],

          'manufacturer': row['manufacturer'] ?? '',
          'price': (row['price'] is num) ? (row['price'] as num).toDouble() : 0.0,

          'mainimage': mainImage,
          'topimage': topImage,
          'backimage': backImage,
          'sideimage': sideImage,
        };

        await txn.insert("goods", insertData);
        insertCount++;
      }

      // 6) purchase
      // ✅ 중복 기준 강화: userid + gseq + gsize + gcolor + pdate
      for (final row in ExampleData.purchases) {
        final exists = await txn.query(
          "purchase",
          where: "userid = ? AND gseq = ? AND gsize = ? AND gcolor = ? AND pdate = ?",
          whereArgs: [
            row['userid'],
            row['gseq'],
            row['gsize'],
            row['gcolor'],
            row['pdate'],
          ],
          limit: 1,
        );

        if (exists.isEmpty) {
          await txn.insert("purchase", row);
        }
      }

      // 7) refund (기준: rdate + rpseq) - 기존 유지
      for (final row in ExampleData.refunds) {
        final exists = await txn.query(
          "refund",
          where: "rdate = ? AND rpseq = ?",
          whereArgs: [row['rdate'], row['rpseq']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("refund", row);
        }
      }

      // 8) approval (기준: adate + aoseq) - 기존 유지
      for (final row in ExampleData.approvals) {
        final exists = await txn.query(
          "approval",
          where: "adate = ? AND aoseq = ?",
          whereArgs: [row['adate'], row['aoseq']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("approval", row);
        }
      }

      // 9) orders (기준: odate + oamount) - 기존 유지
      for (final row in ExampleData.orders) {
        final exists = await txn.query(
          "orders",
          where: "odate = ? AND oamount = ?",
          whereArgs: [row['odate'], row['oamount']],
          limit: 1,
        );
        if (exists.isEmpty) {
          await txn.insert("orders", row);
        }
      }
    });

    print('[SeedData] goods 초기화 완료. 총 $insertCount 개의 새로운 상품 옵션이 삽입되었습니다.');
    print('[SeedData] 데이터베이스 초기화 완료.');
    print('======================================================');
  }
}
