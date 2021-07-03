import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future uploadingDialog(String text){
  return Get.dialog(
    SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xff5458e1),),
                SizedBox(width:30),
                Text(text),
              ],
            ),
          ),
        )
      ], 
    ),
    barrierDismissible: false
  );
}