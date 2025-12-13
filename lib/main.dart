import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/controller/store_controller.dart';
import 'package:xyz_project_01/view/customer/c_login.dart';
import 'package:xyz_project_01/vm/database/seed_data.dart'; // SeedData import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐️ DB 초기화 및 예시 데이터 삽입 로직 호출
  final seed = SeedData();
  await seed.insertExampleData();

  Get.put(StoreController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ),
        ),
      ),
      // 시작 페이지는 GMain이 아닌 CLogin으로 가정하고 그대로 둡니다.
      home: CLogin(),
      // 만약 바로 GMain을 보려면 home: GMain()으로 변경하세요.
    );
  }
}
