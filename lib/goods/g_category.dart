import 'package:flutter/material.dart';

class GCategory extends StatefulWidget {
  const GCategory({super.key});

  @override
  State<GCategory> createState() => _GCategoryState();
}

class _GCategoryState extends State<GCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/xyz_logo.png', // 이미지 경로
          height: 70,
          width: 70,
          fit: BoxFit.contain,
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
    );
  }
}