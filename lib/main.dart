import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:warranty_tracker/Screens/Auth/SplashScreen.dart';
import 'package:warranty_tracker/Screens/HomePage.dart';
import 'package:warranty_tracker/Screens/Auth/LoginPage.dart';
import 'package:warranty_tracker/Screens/Auth/OnBoardPage.dart';
import 'package:warranty_tracker/Services/NotificationService.dart';
import 'package:warranty_tracker/Services/ThemeService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  NotificationService().init();
  runApp(Myapp());
}

class Myapp extends StatelessWidget {

  final storage = GetStorage();
   
  @override
  Widget build(BuildContext context) {

    bool isFirstLogin = storage.read('firstLogin') ?? true;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeService().getCurrentThemeMode(),
      home: isFirstLogin ? OnboardPage() : SpalshScreen(),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center( 
              child: CircularProgressIndicator(
                backgroundColor: Color(0xff5458e1)
              )
            )
          );
        } else {
          if (snapshot.hasData) {
            return HomePage();
           
          } else {
            return LoginPage();
          }
        }
      }
    );
  }
}