import 'dart:async';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'Home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen() : super();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    goToNext();
  }

  void goToNext() {
    Timer(
      Duration(seconds: 3),
      () async => Navigator.pushReplacement(
        context,
        PageTransition(
          child: await RedHome(),
          type: PageTransitionType.rightToLeftWithFade,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/BG.jpg'), fit: BoxFit.cover)),
          child: Column(
            children: [
              Expanded(child: Container()),
              SizedBox(
                height: 150.0,
                child: Image.asset("assets/logo.png"),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: LoadingAnimationWidget.progressiveDots(
                  color: Color.fromARGB(255, 0, 255, 26),
                  size: 50,
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 20,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Developed by Aizotech',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )
         
          ),
    );
  }
}
