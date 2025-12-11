import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xyz_project_01/vm/database/database_handler.dart';
import 'package:xyz_project_01/vm/database/example_data.dart';


class SeedData {
  final DatabaseHandler handler = DatabaseHandler();

  Future<Uint8List?> _loadImageOrNull(String? path) async {
    if (path == null || path.isEmpty) return null;
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<void> insertExampleData() async {
    final db = await handler.initializeDB();

    // 예시 데이터 입력을 위한 코드

    // 여기서 기준: 중복된 예시 데이터가 또 들어가는지 판단하는 기준

    // 1) customer (기준: cemail)
    for (final row in ExampleData.customers) {
      final exists = await db.query(
        "customer",
        where: "cemail = ?",
        whereArgs: [row['cemail']],
      );
      if (exists.isEmpty) {
        await db.insert("customer", row);
      }
    }

    // 2) goods (기준: gname + gsize + gcolor)
    Uint8List? commonMainImage;
    Uint8List? commonTopImage;
    Uint8List? commonBackImage;
    Uint8List? commonSideImage;

    if (ExampleData.goods.isNotEmpty) {
      final first = ExampleData.goods.first;
      commonMainImage =
          await _loadImageOrNull(first['mainimagePath'] as String?);
      commonTopImage =
          await _loadImageOrNull(first['topimagePath'] as String?);
      commonBackImage =
          await _loadImageOrNull(first['backimagePath'] as String?);
      commonSideImage =
          await _loadImageOrNull(first['sideimagePath'] as String?);
    }

    for (final row in ExampleData.goods) {
      final exists = await db.query(
        "goods",
        where: "gname = ? AND gsize = ? AND gcolor = ?",
        whereArgs: [
          row['gname'],
          row['gsize'],
          row['gcolor'],
        ],
      );

      if (exists.isEmpty) {
        final insertData = {
          'gsumamount': row['gsumamount'],
          'gname': row['gname'],
          'gengname': row['gengname'],
          'gsize': row['gsize'],
          'gcolor': row['gcolor'],
          'gcategory': row['gcategory'],
          'mainimage': commonMainImage,
          'topimage': commonTopImage,
          'backimage': commonBackImage,
          'sideimage': commonSideImage,
        };

        await db.insert("goods", insertData);
      }
    }

    // 3) branch (기준: bid)
    for (final row in ExampleData.branches) {
      final exists = await db.query(
        "branch",
        where: "bid = ?",
        whereArgs: [row['bid']],
      );
      if (exists.isEmpty) {
        await db.insert("branch", row);
      }
    }

    // 4) employee (기준: eemail)
    for (final row in ExampleData.employees) {
      final exists = await db.query(
        "employee",
        where: "eemail = ?",
        whereArgs: [row['eemail']],
      );
      if (exists.isEmpty) {
        await db.insert("employee", row);
      }
    }

    // 5) supplier (기준: sid)
    for (final row in ExampleData.suppliers) {
      final exists = await db.query(
        "supplier",
        where: "sid = ?",
        whereArgs: [row['sid']],
      );
      if (exists.isEmpty) {
        await db.insert("supplier", row);
      }
    }

    // 6) purchase (기준: pdate + pamount 조합으로 판단)
    for (final row in ExampleData.purchases) {
      final exists = await db.query(
        "purchase",
        where: "pdate = ? AND pamount = ?",
        whereArgs: [row['pdate'], row['pamount']],
      );
      if (exists.isEmpty) {
        await db.insert("purchase", row);
      }
    }

    // 7) refund (기준: rdate + rpseq)
    for (final row in ExampleData.refunds) {
      final exists = await db.query(
        "refund",
        where: "rdate = ? AND rpseq = ?",
        whereArgs: [row['rdate'], row['rpseq']],
      );
      if (exists.isEmpty) {
        await db.insert("refund", row);
      }
    }

    // 8) approval (기준: adate + aoseq)
    for (final row in ExampleData.approvals) {
      final exists = await db.query(
        "approval",
        where: "adate = ? AND aoseq = ?",
        whereArgs: [row['adate'], row['aoseq']],
      );
      if (exists.isEmpty) {
        await db.insert("approval", row);
      }
    }

    // 9) orders (기준: odate + oamount)
    for (final row in ExampleData.orders) {
      final exists = await db.query(
        "orders",
        where: "odate = ? AND oamount = ?",
        whereArgs: [row['odate'], row['oamount']],
      );
      if (exists.isEmpty) {
        await db.insert("orders", row);
      }
    }
  }
}
