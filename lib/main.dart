// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/controller/store_controller.dart';
import 'package:xyz_project_01/view/customer/c_login.dart';
import 'package:xyz_project_01/vm/database/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(StoreController(), permanent: true);

  runApp(const MyApp());


  // 디버그에서만 실행
  if (kDebugMode) {
    try {
      final seed = SeedData();
      await seed.insertExampleData();
      debugPrint('[SeedData] done');
    } catch (e, st) {
      debugPrint('[SeedData] failed: $e');
      debugPrint('$st');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      home: CLogin(),
    );
  }
}
