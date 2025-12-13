import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/customer_database.dart';

import 'package:xyz_project_01/view/customer/c_find_id.dart';
import 'package:xyz_project_01/view/customer/c_find_pw.dart';
import 'package:xyz_project_01/view/customer/c_regist.dart';
import 'package:xyz_project_01/view/employee/e_login.dart';
import 'package:xyz_project_01/view/goods/g_tabbar.dart';
import 'package:xyz_project_01/view/supplier/s_login.dart';

class CLogin extends StatefulWidget {
  const CLogin({super.key});

  @override
  State<CLogin> createState() => _CLoginState();
}

class _CLoginState extends State<CLogin> {
  late final TextEditingController idController;
  late final TextEditingController pwController;

  late final CustomerDatabase customer;

  late bool i; // 로그인 체크(기존 변수 유지)
  late int imageTapCount;

  final Message message = const Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    customer = CustomerDatabase();

    i = false;
    imageTapCount = 0;
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
                  child: GestureDetector(
                    onTap: () {
                      // 이메일 입력창이 xyz일 때만 3번 탭하면 직원 로그인으로 이동(기존 로직 유지)
                      if (idController.text.trim() == 'xyz') {
                        imageTapCount++;
                        if (imageTapCount >= 3) {
                          imageTapCount = 0;
                          Get.offAll(() => const ELogin());
                        }
                      }
                    },
                    child: Image.asset(
                      'images/welcome.png',
                      scale: 4,
                    ),
                  ),
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
                        onPressed: () => Get.to(() => const CRegist()),
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
                        onPressed: () => Get.to(() => const CFindId()),
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
                        onPressed: () => Get.to(() => const CFindPw()),
                        child: const Text('비밀번호 찾기'),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.to(() => const SLogin()),
                        child: const Text(
                          '제조사 로그인하기',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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

    final result = await customer.loginCheck(id, pw);

    if (result) {
      Get.defaultDialog(
        title: '로그인',
        middleText: '로그인 되었습니다.',
        backgroundColor: const Color.fromARGB(255, 193, 197, 201),
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () => Get.offAll(() => GTabbar(userid: id)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    } else {
      // id, pw가 틀렸을 경우
      i = false;
      message.error('오류', '아이디 또는 비밀번호가 틀렸습니다.');
    }

    setState(() {});
  }
}
