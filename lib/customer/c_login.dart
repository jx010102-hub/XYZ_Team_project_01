import 'package:flutter/material.dart';

class CLogin extends StatefulWidget {
  const CLogin({super.key});

  @override
  State<CLogin> createState() => _CLoginState();
}

class _CLoginState extends State<CLogin> {
  // Property
  late TextEditingController idController;
  late TextEditingController pwController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
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
                    //
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
                        //
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
                        //
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
                        //
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
  }
}