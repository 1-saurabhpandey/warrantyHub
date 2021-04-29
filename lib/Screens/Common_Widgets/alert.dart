import 'package:flutter/material.dart';

Future alertWidget(BuildContext context, String alertMessage){
   
    return  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
          title: Text('Sorry...'),
          content: Text(alertMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    ); 
  }