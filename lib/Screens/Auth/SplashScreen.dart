import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warranty_tracker/main.dart';


// class SplashScreen extends StatelessWidget {

//   final Tween<double> _scale = Tween<double>(begin: 0, end: 1.3);

//   @override
//   Widget build(BuildContext context) {
   
//     return Scaffold(

//       backgroundColor: Theme.of(context).cardColor,

//       body: Center(
//         child: TweenAnimationBuilder(
//           onEnd: (){
            
//             Timer(Duration(milliseconds: 1000), () => Get.off(() => App()));
        
//           },
            
//           tween: _scale,
//           duration: Duration(milliseconds: 1000),
//           builder: (BuildContext context,double scale, Widget? child){
//             return Transform.scale(scale: scale, child: child);
//           },
//           child: Container(
//             child: Text('W'),
//           ),
//         )
//       ),
//     );
//   }
// }

class Spalsh extends StatefulWidget {
  @override
  _SpalshState createState() => _SpalshState();
}

class _SpalshState extends State<Spalsh> with TickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {

    super.initState();

    controller = AnimationController(
      vsync: this,
      duration:const Duration(milliseconds: 1500)
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();

    Timer(Duration(milliseconds: 3000), () => Get.off(() => App()));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Theme.of(context).cardColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FadeTransition(
          opacity: animation,
          child: AvatarGlow(
            glowColor: Color(0xff5458e1),
            endRadius: 80,
            child: Material(
              elevation: 8,
              shape: CircleBorder(),
              child: CircleAvatar(
                backgroundImage: AssetImage('lib/images/logo/logo.jpg'),
                radius: 55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}