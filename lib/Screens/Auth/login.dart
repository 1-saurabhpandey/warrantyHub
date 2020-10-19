import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warranty_tracker/Services/auth.dart';

class Log extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login()
    );
  }
}


class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 120,),
              Container(
                alignment: Alignment.topCenter,
                child: AvatarGlow(
                  glowColor: Colors.deepPurple[900],
                  endRadius: 80,
                  child: Material(
                    elevation: 8,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('lib/images/logo/logo.jpg'),
                      radius: 50,
                    ),
                  ),
                ), 
              ),

              Container(
                child:Text(
                  'WarrantyHub',
                  style: GoogleFonts.meriendaOne(
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
                style:GoogleFonts.raleway(
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
                      dynamic result = AuthService().signInGoogle();
                            
                    if (result == null) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Some error occured'),
                        )
                      );
                    }
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