import 'package:flutter/material.dart';

class EFindId extends StatefulWidget {
  const EFindId({super.key});

  @override
  State<EFindId> createState() => _EFindIdState();
}

class _EFindIdState extends State<EFindId> {
  //Property
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
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
                  '이메일 찾기',
                  style: TextStyle(
                    fontSize: 25
                  ),
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
                  padding: const EdgeInsets.fromLTRB(0, 70, 0, 30),
                  child: ElevatedButton(
                    onPressed: (){
                      //
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(350, 50)
                    ),
                    child: Text('이메일 찾기')
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  } // build
} // class