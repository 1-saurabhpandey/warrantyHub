import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future alertWidget(String alertMessage){
  return Get.dialog( 
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
      title: Text('Sorry...'),
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