import 'package:flutter/material.dart';

class EFindPw extends StatefulWidget {
  const EFindPw({super.key});

  @override
  State<EFindPw> createState() => _EFindPwState();
}

class _EFindPwState extends State<EFindPw> {
 //Property
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('images/logo.png'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      fontSize: 25
                    ),
                  ),
                ),
                TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: '이메일'
                    ),
                  ),
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '이름'
                    ),
                  ),
                TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: '전화번호'
                    ),
                  ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: ElevatedButton(
                      onPressed: (){
                        //
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(350, 50)
                      ),
                      child: Text('비밀번호 찾기')
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  } // build
} // class