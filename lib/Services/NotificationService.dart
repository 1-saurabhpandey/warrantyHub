import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:warranty_tracker/main.dart';

class NotificationService{
  
  static final NotificationService notificationService = NotificationService._internal();

  factory NotificationService(){
    return notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  void init() async{
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('not_logo');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );

    tz.initializeTimeZones();

    await flutterLocalNotificationPlugin.initialize(initializationSettings,onSelectNotification: selectNotification);


  }

  Future selectNotification(String? payload) async{
    Get.off(() => Myapp());
  }

}