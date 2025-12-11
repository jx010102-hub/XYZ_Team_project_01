import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message {
  // Snack Bar
  void snackBar(String itemTitle, String message){
    Get.snackbar(
      itemTitle,
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 1),
      colorText: Colors.white,
      backgroundColor: Colors.red
    );
  } // snackBar

  // Snack Bar
  void oksnackBar(String itemTitle, String message){
    Get.snackbar(
      itemTitle,
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 1),
      colorText: Colors.white,
      backgroundColor: Colors.blue
    );
  } // snackBar

}