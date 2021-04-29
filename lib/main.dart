import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Model/productsModel.dart';
import 'package:warranty_tracker/Screens/Auth/homepage.dart';
import 'package:warranty_tracker/Screens/Auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
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
                backgroundColor: Color(0xff5458e1))));
        } else {
          if (snapshot.hasData) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<DataModel>(create: (_) => DataModel()),

                ChangeNotifierProvider<ProductsModel>(create: (_) => ProductsModel())
              ],
              child: Home(),
            );
           
          } else {
            return Log();
          }
        }
      }
    );
  }
}