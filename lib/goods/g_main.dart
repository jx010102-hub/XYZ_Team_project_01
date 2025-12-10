import 'package:flutter/material.dart';

class GMain extends StatefulWidget {
  const GMain({super.key});

  @override
  State<GMain> createState() => _GMainState();
}

class _GMainState extends State<GMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ImageIcon(
          AssetImage('images/신발가게 로고 1.png'),
          size: 30, // 필요하면 크기 지정
          color: Colors.black, // 색 넣고 싶으면
        ),
        actions: [
          IconButton(
            onPressed: () {
              //
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              //
            },
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Text(
                "오늘의 추천 🔥",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              height: 320, // 카드의 높이 지정
            ),
          ],
        ),
      ),
    );
  }
}
