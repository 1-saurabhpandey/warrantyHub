import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warranty_tracker/Screens/Address_Details/AddressPage.dart';
import 'package:warranty_tracker/Screens/Product_Details/ItemsPage.dart';
import 'package:warranty_tracker/Services/AuthService.dart';
import 'package:warranty_tracker/Services/ThemeService.dart';

class HomePage extends StatelessWidget {

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
      drawer: Drawer(child: buildDrawer(context)),
    );
  }

  Widget buildDrawer(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;

    return Container(
      
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Color(0xff5458e1)),
          accountName: Text(user.displayName!,style: TextStyle(fontSize: 20)),
          accountEmail: Text(user.email!),
          currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(user.photoURL!)),
        ),

        ListTile(
          title: Text('My addresses'),
          leading: Icon(Icons.location_on),
          onTap: () => Get.to(() => AddressPage())
        ),

        ListTile(
          leading: Icon(Icons.lightbulb_outline),
          title: Text('Dark mode'),
          trailing: Switch(
            value: ThemeService().getThemeFromStorage(),  
            onChanged:(val) async {
              ThemeService().changeCurrentTheme();
            },
          ),
        ),

        ListTile(
          title: Text('Sign Out'),
          leading: Icon(Icons.exit_to_app),
          onTap: () async {
            await _auth.signOut();
          },
        ),
      ]),
    );
  }
}