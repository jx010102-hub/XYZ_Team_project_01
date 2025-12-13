import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/employee_database.dart';

import 'package:xyz_project_01/view/admin_/a_main.dart';
import 'package:xyz_project_01/view/employee/e_find_id.dart';
import 'package:xyz_project_01/view/employee/e_find_pw.dart';
import 'package:xyz_project_01/view/employee/e_regist.dart';

class ELogin extends StatefulWidget {
  const ELogin({super.key});

  @override
  State<ELogin> createState() => _ELoginState();
}

class _ELoginState extends State<ELogin> {
  late final TextEditingController idController;
  late final TextEditingController pwController;

  late final EmployeeDatabase employee;

  late bool i; // 로그인 체크(기존 변수 유지)

  final Message message = const Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();

    employee = EmployeeDatabase();

    i = false;
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Image.asset('images/admin_logo.png'),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: '이메일 주소',
                      hintText: 'ex) xyzsuper@xyz.co.kr',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: TextField(
                    controller: pwController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                    ),
                    obscureText: true,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
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

                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Get.to(() => const ERegist()),
                        child: const Text('회원가입'),
                      ),
                      SizedBox(
                        height: 20, // 높이 제어(간격용 아님) → 유지
                        child: VerticalDivider(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const EFindId()),
                        child: const Text('이메일 찾기'),
                      ),
                      SizedBox(
                        height: 20, // 높이 제어(간격용 아님) → 유지
                        child: VerticalDivider(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const EFindPw()),
                        child: const Text('비밀번호 찾기'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkLogin() async {
    // id, pw가 비어있을 경우
    if (idController.text.trim().isEmpty || pwController.text.trim().isEmpty) {
      i = true;
      message.error('오류', '아이디 또는 비밀번호가 틀렸습니다.');
      setState(() {});
      return;
    }

    // 정상적인 경우
    final id = idController.text.trim();
    final pw = pwController.text.trim();

    final result = await employee.loginCheck(id, pw);

    if (result) {
      Get.defaultDialog(
        title: '로그인',
        middleText: '로그인 되었습니다.',
        backgroundColor: const Color.fromARGB(255, 193, 197, 201),
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () => Get.offAll(() => const AMain()),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    } else {
      i = false;
      message.error('오류', '아이디 또는 비밀번호가 틀렸습니다.');
    }

    setState(() {});
  }
}
