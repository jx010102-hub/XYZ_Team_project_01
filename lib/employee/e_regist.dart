import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/employee/e_login.dart';
import 'package:xyz_project_01/model/employee.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/employee_database.dart';

class ERegist extends StatefulWidget {
  const ERegist({super.key});

  @override
  State<ERegist> createState() => _ERegistState();
}

class _ERegistState extends State<ERegist> {
  //Property
  late TextEditingController idController;
  late TextEditingController pwController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late EmployeeDatabase customer;

  late bool _isIdChecked;
  String _checkedEmail = '';

  final Map<String, int> rankMap = {
    '사원': 1,
    '팀장': 2,
    '이사': 3,
    '임원': 4,
  };

  String? selectedRank;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    customer = EmployeeDatabase();
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
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('images/logo.png'),
              ),
              Text('회원가입', style: TextStyle(fontSize: 25)),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: '이메일 주소',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  30,
                  0,
                  30,
                ),
                child: ElevatedButton(
                  onPressed: () async{
                    await checkId(ok: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(350, 50),
                  ),
                  child: Text('중복확인'),
                ),
              ),
              TextField(
                controller: pwController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Text('직급:  '),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                    child: DropdownButton<String>(
                      hint: Text('선택'),
                      value: selectedRank,
                      items: rankMap.keys.map((rankName) {
                        return DropdownMenuItem(
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

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  30,
                  0,
                  30,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    checkRegister();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(350, 50),
                  ),
                  child: Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  void checkRegister() async {
    int result = checkData(); 
    if (result != 0) {
      return;
    }
    
    if (!_isIdChecked) {
      message.snackBar('중복확인', '이메일 중복확인을 해주세요');
      return;
    }

    if (selectedRank == null) {
      message.snackBar('직급', '직급을 선택하세요');
      return;
    }

    final erankValue = rankMap[selectedRank]!;

    var userlist = Employee(
      eemail: idController.text.trim(),
      epw: pwController.text.trim(),
      ename: nameController.text.trim(),
      ephone: phoneController.text.trim(),
      erank: erankValue,
      erole: 1,
      epower: 1,
      workplace: 1,
    );

    int insertResult = await customer.insertEmployee(userlist);

    if (insertResult == 0) {
      message.snackBar('DB 오류', 'Data저장시 문제가 발생했습니다');
    } else {
      Get.defaultDialog(
        title: '회원가입',
        middleText: '가입되었습니다.',
        backgroundColor: const Color.fromARGB(255, 193, 197, 201),
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              Get.offAll(const ELogin());
            },
            style: TextButton.styleFrom(
                foregroundColor: Colors.black,
            ),
            child: Text('OK'),
          ),
        ],
      );
    }
  }

  // 중복확인
  Future<int> checkId({bool ok = true}) async{
    final email = idController.text.trim();

    if (email.isEmpty){
      message.snackBar('오류', '이메일 주소를 입력하세요');
      _isIdChecked = false;
      return 1;
    }

    int checkId = await customer.idCheck(email);
    if (checkId > 0) {
      message.snackBar('오류', '이미 존재하는 이메일입니다.');
      _isIdChecked = false;
      return 1;
    } else {
      _isIdChecked = true;
      _checkedEmail = email;

      if (ok) {
        message.oksnackBar('중복확인', '사용 가능한 이메일입니다.');
      }
      return 0;
    }
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

  int checkData(){
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

    for (var check in checks) {
      if (check['condition']) {
        message.snackBar(check['title'], check['message']);
        result++;
      }
    }
    return result;
  }
} // class
