import 'package:flutter/material.dart';
import 'package:get/get.dart';

snackBar(String message){
  return Get.snackbar(
    '','',
    duration: Duration(seconds: 3),
    titleText: Container(),
    messageText: Text(message,style: TextStyle(color: Colors.white)),
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 10,
    margin: EdgeInsets.all(7),
    colorText: Colors.white,
    backgroundColor: Get.isDarkMode ? Color(0xff363636 ) : Colors.black
    
  );
}