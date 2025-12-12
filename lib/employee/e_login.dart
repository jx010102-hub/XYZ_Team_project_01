import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:xyz_project_01/employee/e_find_id.dart'; // 삭제
// import 'package:xyz_project_01/employee/e_find_pw.dart'; // 삭제
// import 'package:xyz_project_01/employee/e_regist.dart'; // 삭제
import 'package:xyz_project_01/goods/g_tabbar.dart'; // 로그인 성공 시 이동할 페이지
import 'package:xyz_project_01/util/message.dart';
// EmployeeDatabase를 가져오는 경로는 기존 코드를 그대로 유지했습니다.
import 'package:xyz_project_01/vm/database/employee_database.dart'; 

class ELogin extends StatefulWidget {
  const ELogin({super.key});

  @override
  State<ELogin> createState() => _ELoginState();
}

class _ELoginState extends State<ELogin> {
  // Property
  late TextEditingController idController;
  late TextEditingController pwController;
  late EmployeeDatabase employee;
  
  // 로그인 체크 변수는 UI 변경에 사용되지 않으므로 제거하거나 주석 처리해도 무방하지만,
  // 기존 코드에 있었으므로 일단 유지합니다.
  late bool i; 

  // 유저에게 메시지를 띄우는 헬퍼 클래스
  Message message = Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    // 데이터베이스 핸들러 초기화
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
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  50,
                ),
                child: Image.asset('images/admin_logo.png'),
              ),
              
              // 이메일 주소 입력 필드
              TextField(
                controller: idController,
                keyboardType: TextInputType.emailAddress, // 이메일 입력 타입으로 변경
                decoration: const InputDecoration(
                  labelText: '이메일 주소',
                  hintText: 'ex) admin@xyz.co.kr', // 예시 변경 (DB 시드 데이터 기준)
                ),
              ),
              
              // 비밀번호 입력 필드
              TextField(
                controller: pwController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true, // 비밀번호 보호를 위해 true로 변경했습니다.
              ),
              
              // 로그인 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  30,
                  0,
                  30,
                ),
                child: ElevatedButton(
                  onPressed: checkLogin, // 함수 이름만 전달
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(350, 50),
                  ),
                  child: const Text('로그인'),
                ),
              ),
              
              // ----------------------------------------------------
              // 하단 버튼 (회원가입, 이메일 찾기, 비밀번호 찾기) 모두 제거
              // ----------------------------------------------------
            ],
          ),
        ),
      ),
    );
  } // build

  // ⭐️⭐️⭐️ 로그인 체크 함수: DB와의 연동 핵심 로직 ⭐️⭐️⭐️
  void checkLogin() async {
    final id = idController.text.trim();
    final pw = pwController.text.trim();

    // 1. 유효성 검사 (빈 칸 체크)
    if (id.isEmpty || pw.isEmpty) {
      message.snackBar('오류', '이메일 주소와 비밀번호를 모두 입력해주세요.');
      return;
    }

    // 2. DB 로그인 체크
    final result = await employee.loginCheck(id, pw);
    
    if (result) {
      // 3. 로그인 성공: GTabbar로 이동
      Get.defaultDialog(
        title: '로그인',
        middleText: '로그인 되었습니다.',
        backgroundColor: const Color.fromARGB(
          255,
          193,
          197,
          201,
        ),
        barrierDismissible: false,
        actions: [
          TextButton(
            // Get.offAll()을 사용하여 이전 페이지 스택을 모두 제거하고 새 페이지로 이동
            onPressed: () {
              // GTabbar(userid: id) 로 이동
              Get.offAll(() => GTabbar(userid: id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    } else {
      // 4. 로그인 실패: 오류 메시지 출력
      message.snackBar('오류', '아이디 또는 비밀번호가 틀렸습니다.');
    }
  }
}