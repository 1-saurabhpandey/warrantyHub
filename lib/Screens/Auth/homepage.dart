import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:warranty_tracker/Screens/Address_Details/addresspage.dart';
import 'package:warranty_tracker/Screens/Product_Details/items.dart';
import 'package:warranty_tracker/Services/auth.dart';
import 'package:warranty_tracker/main.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xff5458e1),
          selectionHandleColor: Color(0xff5458e1),
          cursorColor: Color(0xff5458e1)
        ),
         
        accentColor: Color(0xff5458e1),
        primaryColor: Color(0xff5458e1),
        colorScheme: ColorScheme.light(primary: const Color(0xff5458e1)),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService(); 

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WarrantyHub'),
        backgroundColor: Color(0xff5458e1),
        elevation: 0,
      ),
      body: Builder(builder: (context) => Items()), 
      drawer: Drawer(child: buildDrawer()),
    );
  }

  Widget buildDrawer() {
    User user = FirebaseAuth.instance.currentUser!;

    return ListView(
      children: <Widget>[
      UserAccountsDrawerHeader(
        decoration: BoxDecoration(color: Color(0xff5458e1)),
        accountName: Text(user.displayName!),
        accountEmail: Text(user.email!),
        currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(user.photoURL!)),
      ),
      ListTile(
        title: Text('My addresses'),
        leading: Icon(Icons.location_on),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddressPage())),
      ),
      ListTile(
        title: Text('Sign Out'),
        leading: Icon(Icons.exit_to_app),
        onTap: () async {
          
          await _auth.signOut();
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => App()));
        },
      ),
    ]);
  }
}