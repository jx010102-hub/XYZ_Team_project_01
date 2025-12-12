import 'package:flutter/material.dart';

class SMain extends StatefulWidget {
  final String sid;
  const SMain({super.key, required this.sid});

  @override
  State<SMain> createState() => _SMainState();
}

class _SMainState extends State<SMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png',
          height: 70,
          width: 70,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '승인요청',
                      style: TextStyle(fontSize: 15),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('모든매장', style: TextStyle(fontSize: 14)),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      '총 0건',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                padding: const EdgeInsets.symmetric(vertical: 40),
                color: Colors.grey.shade300,
                child: Expanded(
                  child: Center(
                    child: Text(
                      "승인 요청이 없습니다.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 24),
              child: Container(
                width: 160,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "승인",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
