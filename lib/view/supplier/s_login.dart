import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/view/supplier/s_main.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/supplier_database.dart';

class SLogin extends StatefulWidget {
  const SLogin({super.key});

  @override
  State<SLogin> createState() => _SLoginState();
}

class _SLoginState extends State<SLogin> {
  late final TextEditingController idController;
  late final TextEditingController nameController;
  late final SupplierDatabase supplier;

  final Message message = Message();

  // ✅ 미사용/더미 정리: i, imageTapCount 제거

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    nameController = TextEditingController();
    supplier = SupplierDatabase();
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Image.asset(
                      'images/supplier_logo.png',
                      scale: 8,
                    ),
                  ),
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: '제조사 아이디를 입력하세요',
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '제조사 이름을 입력하세요',
                    ),
                    obscureText: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 60),
                    child: ElevatedButton(
                      onPressed: checkLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(350, 50),
                      ),
                      child: const Text('로그인'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkLogin() async {
    final id = idController.text.trim();
    final name = nameController.text.trim();

    // ✅ 입력값 체크 (기능 동일)
    if (id.isEmpty || name.isEmpty) {
      message.error('오류', '제조사 아이디와 이름이 올바르지 않습니다.');
      return;
    }

    try {
      final result = await supplier.loginCheck(id, name);

      if (!mounted) return;

      if (result) {
        Get.defaultDialog(
          title: '로그인',
          middleText: '로그인 되었습니다.',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () => Get.offAll(SMain(sid: id, sname: name)),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('OK'),
            ),
          ],
        );
      } else {
        message.error('오류', '제조사 아이디와 이름이 올바르지 않습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      message.error('오류', '로그인 처리 중 오류: $e');
    }
  }
}
