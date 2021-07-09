import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future alertWidget(String title, String alertMessage){
  return Get.dialog( 
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
      title: Center(child: Text(title)),
      content: Text(alertMessage),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Get.back();
          },
        )
      ],
    )
  );
}