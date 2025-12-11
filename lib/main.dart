import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/customer/c_login.dart';
import 'package:xyz_project_01/goods/g_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ),
        ),
      ),
      home: CLogin(),
    );
  }
}
