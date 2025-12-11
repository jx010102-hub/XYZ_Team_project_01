import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/customer/c_find_id.dart';
import 'package:xyz_project_01/customer/c_find_pw.dart';
import 'package:xyz_project_01/customer/c_regist.dart';
import 'package:xyz_project_01/goods/g_tabbar.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/customer_database.dart';

class CLogin extends StatefulWidget {
  const CLogin({super.key});

  @override
  State<CLogin> createState() => _CLoginState();
}

class _CLoginState extends State<CLogin> {
  // Property
  late TextEditingController idController;
  late TextEditingController pwController;
  late CustomerDatabase customer;
  late bool i; // 로그인 체크

  Message message = Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    customer = CustomerDatabase();
    i = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: Image.asset('images/welcome.png',
                scale: 4,),
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: '이메일 주소',
                  hintText: 'ex) xyzsuper@xyz.co.kr'
                ),
              ),
              TextField(
                controller: pwController,
                decoration: InputDecoration(
                  labelText: '비밀번호'
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: ElevatedButton(
                  onPressed: (){
                    checkLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(350, 50)
                  ),
                  child: Text('로그인')
                ),
              ),
              IntrinsicHeight(
                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: (){
                        Get.to(CRegist());
                      },
                      child: Text('회원가입')
                    ),
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                      Get.to(CFindId());
                      },
                      child: Text('이메일 찾기')
                    ),
                    SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                      Get.to(CFindPw());
                      },
                      child: Text('비밀번호 찾기')
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  } // build

  void checkLogin() async{
    // id, pw가 비어있을 경우
    if(idController.text.trim().isEmpty ||
       pwController.text.trim().isEmpty){
      i=true;
      message.snackBar('오류', '아이디 또는 비밀번호가 틀렸습니다.');
    }else{
    // 정상적인 경우
    final id = idController.text.trim();
    final pw = pwController.text.trim();
    final result = await customer.loginCheck(id, pw);
      if(result){
        Get.defaultDialog(
          title: '로그인',
          middleText: '로그인 되었습니다.',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(GTabbar(userid: id));
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
              ),
              child: Text('OK'),
            ),
          ],
        );
      }else{
    // id, pw가 틀렸을 경우
        i=false;
        message.snackBar('오류', '아이디 또는 비밀번호가 틀렸습니다.');
      }
    }
    setState(() {});
  }


} // class