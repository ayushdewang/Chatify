import 'dart:developer';

import 'package:chat_app/helper/dialog.dart';
import 'package:chat_app/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/usermodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 3),(){
      setState(() {
        isAnimate = true;
      });
    });
  }
  _onGoogleButtonClick(){
    Dialogs.showProgressbar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user != null){
        if(await UserModel.userExist()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
        }
        else{
          await UserModel.createUser().then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
          });
        }
      }

  });
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
    catch (e){
      log("signInWithGoogle:- ${e}");
      Dialogs.showSnackbar(context, "Something went wrong (Check Internet!)");
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    scr_size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to Chatify"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(seconds: 1),
              top: scr_size.height *.15,
              right: isAnimate ? scr_size.width *.25 : -scr_size.width * .5,
              width: scr_size.width *.5,
              child: Image.asset("assets/icons/chat.png",height: 130,)),
          Positioned(
              top: scr_size.height * .40,
              left: scr_size.width *.15,
              height: scr_size.height * 0.05,
              width: scr_size.width * 0.7,
              child: SignInButton(
                Buttons.googleDark,
                text: "Sign in with Google",
                onPressed: () {
                  _onGoogleButtonClick();
                   },
              ),)
        ],
      ),
    );
  }
}
