import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xyz_project_01/model/employee.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/employee_database.dart';
import 'package:xyz_project_01/view/employee/e_login.dart';

class ERegist extends StatefulWidget {
  const ERegist({super.key});

  @override
  State<ERegist> createState() => _ERegistState();
}

class _ERegistState extends State<ERegist> {
  late final TextEditingController idController;
  late final TextEditingController pwController;
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  late final EmployeeDatabase employee;
  late bool _isIdChecked;
  String _checkedEmail = '';

  final Map<String, int> rankMap = const {
    '사원': 1,
    '팀장': 2,
    '이사': 3,
    '임원': 4,
  };

  String? selectedRank;

  final Message message = const Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();

    employee = EmployeeDatabase();

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
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('직급:  '),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: DropdownButton<String>(
                          hint: const Text('선택'),
                          value: selectedRank,
                          items: rankMap.keys.map((rankName) {
                            return DropdownMenuItem<String>(
                              value: rankName,
                              child: Text(rankName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRank = value;
                            });
                          },
                        ),
                      ),
                    ],
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

    if (selectedRank == null) {
      message.error('직급', '직급을 선택하세요');
      return;
    }

    final erankValue = rankMap[selectedRank]!;

    final user = Employee(
      eemail: idController.text.trim(),
      epw: pwController.text.trim(),
      ename: nameController.text.trim(),
      ephone: phoneController.text.trim(),
      erank: erankValue,
      erole: 1,
      epower: 1,
      workplace: 1,
    );

    final int insertResult = await employee.insertEmployee(user); // ✅

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
          onPressed: () => Get.offAll(() => const ELogin()),
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

    final int checkId = await employee.idCheck(email); // ✅

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

  void _onIdChanged() {
    final current = idController.text.trim();
    if (_isIdChecked && current != _checkedEmail) {
      setState(() {
        _isIdChecked = false;
      });
    }
  }

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
