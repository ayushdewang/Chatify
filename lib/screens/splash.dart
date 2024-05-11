import 'dart:async';
import 'dart:developer';
import 'package:chat_app/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      if(FirebaseAuth.instance.currentUser != null){
        log("user:- ${FirebaseAuth.instance.currentUser}");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
      }
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black12,spreadRadius: 0.5,blurRadius: 1)
              ]
            ),
              child: Image.asset("assets/icons/splash.png",height: 100,)),
        ),
      ),
    );
  }
}
