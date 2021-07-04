import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;


class NotificationViewmodel extends GetxController{

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'channelId', 
      'channelName', 
      'channelDescription',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'not_logo',
      color: Color(0xff5458e1)
    )
  );

  void setNotification(Map productDetails) async{

    int notificationId = int.parse(productDetails['id'].split('P').last);

    var format = DateFormat('dd/MM/yyyy');
    String date = format.format(productDetails['expiry']);

    if(DateTime.now().isBefore(productDetails['expiry'])){

      var difference  = DateTime.now().difference(productDetails['expiry']).inDays;

      if(difference > 30){

        await FlutterLocalNotificationsPlugin().zonedSchedule(                
          notificationId, 
          'A notification', 
          'Test Notification', 
          tz.TZDateTime.from(productDetails['expiry'], tz.local).subtract(Duration(days: 30)), 
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
          androidAllowWhileIdle: true
        );

        await FlutterLocalNotificationsPlugin().zonedSchedule(
          notificationId, 
          'A notification',  
          'Test Notification', 
          tz.TZDateTime.from(productDetails['expiry'], tz.local).subtract(Duration(days: 15)), 
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
          androidAllowWhileIdle: true
        );


        await FlutterLocalNotificationsPlugin().zonedSchedule(
          notificationId, 
          'A notification', 
          'Test Notification', 
          tz.TZDateTime.from(productDetails['expiry'], tz.local).subtract(Duration(days: 7)),
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
          androidAllowWhileIdle: true
        );

        await FlutterLocalNotificationsPlugin().zonedSchedule(
          notificationId, 
          'A notification', 
          'Test Notification', 
          tz.TZDateTime.from(productDetails['expiry'], tz.local).subtract(Duration(days: 1)), 
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
          androidAllowWhileIdle: true
        );

        await FlutterLocalNotificationsPlugin().zonedSchedule(
          notificationId, 
          'A notification', 
          'Test Notification', 
          tz.TZDateTime.from(productDetails['expiry'], tz.local).subtract(Duration(hours:1 )), 
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
          androidAllowWhileIdle: true
        );
      }
      else{
        await FlutterLocalNotificationsPlugin().zonedSchedule(
          notificationId, 
          'Product Expiring', 
          'Your Product ${productDetails['name']} is expiring on $date ', 
          tz.TZDateTime.now(tz.local).add(Duration(days: difference - 1)), 
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
          androidAllowWhileIdle: true
        );
      }
    }
  }

  cancelNotification(String notificationId){
    FlutterLocalNotificationsPlugin().cancel(int.parse(notificationId.split('P').last));
  }

}
