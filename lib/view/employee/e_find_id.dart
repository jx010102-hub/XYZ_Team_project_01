import 'package:flutter/material.dart';

class EFindId extends StatefulWidget {
  const EFindId({super.key});

  @override
  State<EFindId> createState() => _EFindIdState();
}

class _EFindIdState extends State<EFindId> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('images/logo.png'),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 70),
                  child: Text(
                    '이메일 찾기',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      //
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(350, 50),
                    ),
                    child: const Text('이메일 찾기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
