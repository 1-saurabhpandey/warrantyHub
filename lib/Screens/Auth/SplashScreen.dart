import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warranty_tracker/main.dart';

class SpalshScreen extends StatefulWidget {
  @override
  _SpalshScreenState createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> with TickerProviderStateMixin {

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
  void dispose() {
    controller.dispose();
    super.dispose();
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
                backgroundImage: AssetImage('lib/images/logo/logo.png'),
                radius: 55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}