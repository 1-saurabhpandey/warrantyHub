import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Auth/homepage.dart';
import 'package:warranty_tracker/Screens/Auth/login.dart';
import 'package:warranty_tracker/Screens/Auth/onboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(

      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot){

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.data.getBool('first_time') == null) {
          snapshot.data.setBool('first_time', false);
          return OnboardingScreen();
        }
        if (snapshot.data.getBool('first_time') != null) {
          return App();
        } else
          return CircularProgressIndicator();
      },
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xff5458e1))));
        } else {
          if (snapshot.hasData) {
            return ChangeNotifierProvider<DataModel>(
              create: (_) => DataModel(), child: Home()
            );
          } else {
            return Log();
          }
        }
      }
    );
  }
}
