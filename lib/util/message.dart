import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 스낵바 모음
class Message {
  const Message();

  // 기본
  void info(String title, String msg) {
    _show(
      title,
      msg,
      background: Colors.black,
    );
  }

  // 성공
  void success(String title, String msg) {
    _show(
      title,
      msg,
      background: Colors.green.shade700,
    );
  }

  // 오류
  void error(String title, String msg) {
    _show(
      title,
      msg,
      background: Colors.red.shade700,
    );
  }

  // 경고
  void warning(String title, String msg) {
    _show(
      title,
      msg,
      background: Colors.orange.shade700,
    );
  }

  // 공통
  void _show(
    String title,
    String msg, {
    required Color background,
  }) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: background,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }
}
