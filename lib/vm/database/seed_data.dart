// lib/vm/database/seed_data.dart 파일 전체 내용

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart'; 
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
      // 이미지 로드 실패 시 로그를 남깁니다.
      print('❌ [SeedData Error] 이미지 로드 실패: $path, 오류: $e');
      return null;
    }
  }

  Future<void> insertExampleData() async {
    final db = await handler.initializeDB();
    int insertCount = 0;
    
    // 같은 gname에 대한 이미지 로딩을 최적화하기 위해 사용
    final Map<String, Uint8List?> loadedImages = {}; 

    print('======================================================');
    print('[SeedData] 데이터베이스 초기화(Seed) 시작');

    // 1) customer (기준: cemail)
    for (final row in ExampleData.customers) {
      final exists = await db.query("customer", where: "cemail = ?", whereArgs: [row['cemail']]);
      if (exists.isEmpty) {
        await db.insert("customer", row);
      }
    }

    // 3) branch (기준: bid)
    for (final row in ExampleData.branches) {
      final exists = await db.query("branch", where: "bid = ?", whereArgs: [row['bid']]);
      if (exists.isEmpty) {
        await db.insert("branch", row);
      }
    }

    // 4) employee (기준: eemail)
    for (final row in ExampleData.employees) {
      final exists = await db.query("employee", where: "eemail = ?", whereArgs: [row['eemail']]);
      if (exists.isEmpty) {
        await db.insert("employee", row);
      }
    }

    // 5) supplier (기준: sid)
    for (final row in ExampleData.suppliers) {
      final exists = await db.query("supplier", where: "sid = ?", whereArgs: [row['sid']]);
      if (exists.isEmpty) {
        await db.insert("supplier", row);
      }
    }
    
    // ⭐️ 2) goods 데이터 삽입 (이미지 포함)
    for (final row in ExampleData.goods) {
      final gname = row['gname'];
      final gsize = row['gsize'];
      final gcolor = row['gcolor'];
      
      // 이미 존재하는지 확인 (중복 상품 옵션 체크)
      final exists = await db.query(
        "goods",
        where: "gname = ? AND gsize = ? AND gcolor = ?",
        whereArgs: [gname, gsize, gcolor],
      );

      if (exists.isEmpty) {
        Uint8List? mainImage;
        Uint8List? topImage;
        Uint8List? backImage;
        Uint8List? sideImage;
        
        // 해당 상품 이름에 대한 이미지가 로드된 적이 없다면 로드하고 캐싱
        if (!loadedImages.containsKey('${gname}_main')) {
            // 이미지 로드 (로깅이 _loadImageOrNull 내부에서 처리됨)
            mainImage = await _loadImageOrNull(row['mainimagePath'] as String?);
            topImage = await _loadImageOrNull(row['topimagePath'] as String?);
            backImage = await _loadImageOrNull(row['backimagePath'] as String?);
            sideImage = await _loadImageOrNull(row['sideimagePath'] as String?);
            
            // 로드된 이미지 저장 (같은 gname의 옵션은 재사용)
            loadedImages['${gname}_main'] = mainImage;
            loadedImages['${gname}_top'] = topImage;
            loadedImages['${gname}_back'] = backImage;
            loadedImages['${gname}_side'] = sideImage;
        } else {
            // 이미 로드된 이미지 재사용
            mainImage = loadedImages['${gname}_main'];
            topImage = loadedImages['${gname}_top'];
            backImage = loadedImages['${gname}_back'];
            sideImage = loadedImages['${gname}_side'];
        }
        
        // DB 삽입 데이터 준비
        final insertData = {
          'gsumamount': row['gsumamount'],
          'gname': gname,
          'gengname': row['gengname'],
          'gsize': gsize,
          'gcolor': gcolor,
          'gcategory': row['gcategory'],
          'mainimage': mainImage, // Uint8List 형태
          'topimage': topImage,
          'backimage': backImage,
          'sideimage': sideImage,
        };

        await db.insert("goods", insertData);
        insertCount++;
      }
    }
    
    print('[SeedData] goods 초기화 완료. 총 $insertCount 개의 새로운 상품 옵션이 삽입되었습니다.');

    // 6) purchase (기준: pdate + pamount 조합으로 판단)
    for (final row in ExampleData.purchases) {
      final exists = await db.query("purchase", where: "pdate = ? AND pamount = ?", whereArgs: [row['pdate'], row['pamount']]);
      if (exists.isEmpty) {
        await db.insert("purchase", row);
      }
    }

    // 7) refund (기준: rdate + rpseq)
    for (final row in ExampleData.refunds) {
      final exists = await db.query("refund", where: "rdate = ? AND rpseq = ?", whereArgs: [row['rdate'], row['rpseq']]);
      if (exists.isEmpty) {
        await db.insert("refund", row);
      }
    }

    // 8) approval (기준: adate + aoseq)
    for (final row in ExampleData.approvals) {
      final exists = await db.query("approval", where: "adate = ? AND aoseq = ?", whereArgs: [row['adate'], row['aoseq']]);
      if (exists.isEmpty) {
        await db.insert("approval", row);
      }
    }

    // 9) orders (기준: odate + oamount)
    for (final row in ExampleData.orders) {
      final exists = await db.query("orders", where: "odate = ? AND oamount = ?", whereArgs: [row['odate'], row['oamount']]);
      if (exists.isEmpty) {
        await db.insert("orders", row);
      }
    }
    print('[SeedData] 데이터베이스 초기화 완료.');
    print('======================================================');
  }
}