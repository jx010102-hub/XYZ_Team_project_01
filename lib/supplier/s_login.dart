import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xyz_project_01/supplier/s_main.dart';
import 'package:xyz_project_01/util/message.dart';
import 'package:xyz_project_01/vm/database/supplier_database.dart';

class SLogin extends StatefulWidget {
  const SLogin({super.key});

  @override
  State<SLogin> createState() => _SLoginState();
}

class _SLoginState extends State<SLogin> {
  // Property
  late TextEditingController idController;
  late TextEditingController nameController;
  late SupplierDatabase supplier;
  late bool i; // 로그인 체크
  late int imageTapCount;

  Message message = Message();

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    nameController = TextEditingController();
    supplier = SupplierDatabase();
    i = false;
    imageTapCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: 
        SingleChildScrollView(
          child: Center(
          child: SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                    child: Image.asset('images/supplier_logo.png',
                    scale: 8,),
                  ),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: '제조사 아이디를 입력하세요',
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '제조사 이름을 입력하세요'
                    ),
                    obscureText: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 60),
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
                ],
              ),
            ),
          ),
                ),
        ),
    );
  } // build

  void checkLogin() async{
    // id, pw가 비어있을 경우
    if(idController.text.trim().isEmpty ||
       nameController.text.trim().isEmpty){
      i=true;
      message.snackBar('오류', '제조사 아이디와 이름이 올바르지 않습니다.');
    }else{
    // 정상적인 경우
    final id = idController.text.trim();
    final name = nameController.text.trim();
    final result = await supplier.loginCheck(id, name);
      if(result){
        Get.defaultDialog(
          title: '로그인',
          middleText: '로그인 되었습니다.',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(SMain(sid: id, sname: name));
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
        message.snackBar('오류', '제조사 아이디와 이름이 올바르지 않습니다.');
      }
    }
    setState(() {});
  }
} // class