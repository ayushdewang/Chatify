import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/dialog.dart';
import '../models/chatmodel.dart';
import 'auth/login.dart';

class ProfileScreen extends StatefulWidget {
  final ChatModel user;
  const ProfileScreen({super.key,required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Profile",style: TextStyle(color: Colors.blue),),
      ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            onPressed: () async{
              Dialogs.showProgressbar(context);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut().then((value) {
                UserModel.updateActiveStatus(false);
                Navigator.pop(context);
                Navigator.pop(context);

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
              });
            },
            icon: Icon(Icons.logout_outlined,color: Colors.white,),
            label: Text("Logout",style: TextStyle(color: Colors.white,fontSize: 16),),
          ),
        ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height*.03),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                    BoxShadow(color: Colors.black12,blurRadius: 0.5,spreadRadius: 2)
                  ]),
                  child: Stack(
                    children: [
                      _image != null ?
                  ClipRRect(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
          child: Image.file(
            File(_image!),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width *.30,
              height: MediaQuery.of(context).size.height *.15,
          ),
        )
                          :
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width *.30,
                            height: MediaQuery.of(context).size.height *.15,
                            imageUrl: widget.user.image,
                            //placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(CupertinoIcons.person,color: Colors.white,),
                            )
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 0,
                        left: 55,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: MaterialButton(onPressed: (){
                            _showBottomSheet();
                          },
                            child: Icon(Icons.edit,color: Colors.blue,size: 20,),
                            color: Colors.white,
                            shape: CircleBorder(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*.03,),
                Text(widget.user.email,style: TextStyle(fontSize: 17,color: Colors.black38),),
                SizedBox(height: MediaQuery.of(context).size.height*.05,),
                TextFormField(
                  onSaved: (val) => UserModel.me.name = val ?? '',
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                  initialValue: widget.user.name,
                  decoration: InputDecoration(
                    hintText: "eg. Happy Singh",
                    label: Text("Name"),
                    prefixIcon: Icon(Icons.person,color: Colors.blue,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*.03,),
                TextFormField(
                  onSaved: (val) => UserModel.me.about = val ?? '',
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                  initialValue: widget.user.about,
                  decoration: InputDecoration(
                      hintText: "eg. Feeling happy",
                      label: Text("About"),
                      prefixIcon: Icon(Icons.info_outline,color: Colors.blue,),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                  ),
                ),
                SizedBox(height: 30,),
                SizedBox(
                  height: 50,
                  width: 180,
                  child: ElevatedButton(onPressed: (){
                    if(_formKey.currentState!.validate()){
                      _formKey.currentState!.save();
                      UserModel.updateUserInfo().then((value){
                        Dialogs.showSnackbar(context, "Profile Updated Successfully");
                      });
                    }
                  },
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit,color: Colors.white,),
                          SizedBox(width: 8,),
                          Text("Update",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
  void _showBottomSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        context: context, builder: (_){
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*.03,bottom: MediaQuery.of(context).size.height*.05),
        children: [
          Text("Pick Profile Picture",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ElevatedButton(onPressed: ()async{
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.camera);
              if(image!=null){
                setState(() {
                  _image = image.path;
                });
                UserModel.updateProfile(File(_image!));
                Navigator.pop(context);
              }
            },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  backgroundColor: Colors.white,
                  fixedSize: Size(MediaQuery.of(context).size.width*.3,MediaQuery.of(context).size.height*.15)
                ),
                child: Image.asset("assets/icons/camera.png")),
            ElevatedButton(onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if(image!=null){
                setState(() {
                  _image = image.path;
                });
                UserModel.updateProfile(File(_image!));
                Navigator.pop(context);
              }
            },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    backgroundColor: Colors.white,
                    fixedSize: Size(MediaQuery.of(context).size.width*.3,MediaQuery.of(context).size.height*.15)
                ),
                child: Image.asset("assets/icons/picture.png")),
          ],)
        ],
      );
    });
  }
  
}
