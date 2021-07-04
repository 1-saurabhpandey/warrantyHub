import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warranty_tracker/Services/AuthService.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 120,),
              Container(
                alignment: Alignment.topCenter,
                child: AvatarGlow(
                  glowColor: Color(0xff5458e1),
                  endRadius: 80,
                  child: Material(
                    elevation: 8,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('lib/images/logo/logo.png'),
                      radius: 50,
                    ),
                  ),
                ), 
              ),

              Container(
                child:Text(
                  'WarrantyHub',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600
                    )
                  )
                )
              ),
              SizedBox(height: 20,),
              Container(
                child: Text('Online Warranty Tracking & Management',
                style:GoogleFonts.montserrat(
                  textStyle:TextStyle(
                    fontSize: 17
                  )
                ) )
              ),
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,60,8,8),
                child: InkWell(
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.deepPurple), 
                      borderRadius: BorderRadius.circular(10)),
                    child: Image(image:AssetImage('lib/images/sign.png'),
                    height: 45,),
                  ),

                  onTap: () async {
                    AuthService().signInGoogle();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}