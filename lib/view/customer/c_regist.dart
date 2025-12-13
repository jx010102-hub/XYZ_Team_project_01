import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/model/customer.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/customer_database.dart';
import 'package:xyz_project_01/view/customer/c_login.dart';

class CRegist extends StatefulWidget {
  const CRegist({super.key});

  @override
  State<CRegist> createState() => _CRegistState();
}

class _CRegistState extends State<CRegist> {
  late final TextEditingController idController;
  late final TextEditingController pwController;
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  late final CustomerDatabase customer;

  late bool _isIdChecked;
  String _checkedEmail = '';

  final Message message = const Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    customer = CustomerDatabase();

    _isIdChecked = false;
    _checkedEmail = '';

    idController.addListener(_onIdChanged);
  }

  @override
  void dispose() {
    idController.removeListener(_onIdChanged);

    idController.dispose();
    pwController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('images/logo.png'),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '회원가입',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: '이메일 주소',
                  ),
                ),

                // (간격용 SizedBox 대신 Padding 유지)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton(
                    onPressed: () async {
                      await checkId(ok: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(350, 50),
                    ),
                    child: const Text('중복확인'),
                  ),
                ),

                TextField(
                  controller: pwController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                  ),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: '전화번호',
                  ),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: '주소',
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton(
                    onPressed: checkRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(350, 50),
                    ),
                    child: const Text('회원가입'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkRegister() async {
    final int result = checkData();
    if (result != 0) return;

    if (!_isIdChecked) {
      message.error('중복확인', '이메일 중복확인을 해주세요');
      return;
    }

    final userlist = Customer(
      cemail: idController.text.trim(),
      cpw: pwController.text.trim(),
      cname: nameController.text.trim(),
      cphone: phoneController.text.trim(),
      caddress: addressController.text,
    );

    final int insertResult = await customer.insertCustomer(userlist);

    if (insertResult == 0) {
      message.error('DB 오류', 'Data저장시 문제가 발생했습니다');
      return;
    }

    Get.defaultDialog(
      title: '회원가입',
      middleText: '가입되었습니다.',
      backgroundColor: const Color.fromARGB(255, 193, 197, 201),
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () => Get.offAll(() => const CLogin()),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }

  // 중복확인
  Future<int> checkId({bool ok = true}) async {
    final email = idController.text.trim();

    if (email.isEmpty) {
      message.error('오류', '이메일 주소를 입력하세요');
      _isIdChecked = false;
      return 1;
    }

    final int checkId = await customer.idCheck(email);

    if (checkId > 0) {
      message.error('오류', '이미 존재하는 이메일입니다.');
      _isIdChecked = false;
      return 1;
    }

    _isIdChecked = true;
    _checkedEmail = email;

    if (ok) {
      message.success('중복확인', '사용 가능한 이메일입니다.');
    }
    return 0;
  }

  // 아이디 수정 시 다시 체크
  void _onIdChanged() {
    final current = idController.text.trim();
    if (_isIdChecked && current != _checkedEmail) {
      setState(() {
        _isIdChecked = false;
      });
    }
  }

  // 입력 체크
  int checkData() {
    final List<Map<String, dynamic>> checks = [
      {
        'condition': idController.text.trim().isEmpty,
        'title': '이메일',
        'message': '이메일 주소를 입력 하세요',
      },
      {
        'condition': pwController.text.trim().isEmpty,
        'title': '비밀번호',
        'message': '비밀번호를 입력 하세요',
      },
      {
        'condition': nameController.text.trim().isEmpty,
        'title': '이름',
        'message': '이름을 입력 하세요',
      },
      {
        'condition': phoneController.text.trim().isEmpty,
        'title': '전화번호',
        'message': '전화번호를 입력 하세요',
      },
      {
        'condition': addressController.text.isEmpty,
        'title': '주소',
        'message': '주소를 입력 하세요',
      },
    ];

    int result = 0;

    for (final check in checks) {
      if (check['condition'] == true) {
        message.error(check['title'] as String, check['message'] as String);
        result++;
      }
    }
    return result;
  }
}
