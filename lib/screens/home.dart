import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/screens/auth/login.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:chat_app/widgets/card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helper/dialog.dart';
import '../models/chatmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _list = [];
  final List _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserModel.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message){
      if(FirebaseAuth.instance.currentUser != null){
        if(message.toString().contains("pause")) UserModel.updateActiveStatus(false);
        if(message.toString().contains("resume")) UserModel.updateActiveStatus(true);
      }
      return Future.value("");
    });
  }
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;

            });
            return Future.value(false);
          }
          else{
            return Future.value(true);
          }

        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home),
            title: _isSearching ? TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search users...",
              ),
              onChanged: (value) {
                _searchList.clear();
                for (var i in _list){
                  if(i.name.toLowerCase().contains(value.toLowerCase()) || i.email.toLowerCase().contains(value.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
              autofocus: true,
            ) : Text("Chatify",style: TextStyle(color: Colors.blue),),
            actions: [
              IconButton(onPressed: (){
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search_outlined)),
              IconButton(onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: UserModel.me,),));
              }, icon: Icon(Icons.more_vert)),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              shape: CircleBorder(),
              onPressed:(){},
              child: Icon(Icons.chat),
            ),
          ),
          body: StreamBuilder(
            stream: UserModel.getAllUsers(),
            builder: (context, snapshot){
              switch (snapshot.connectionState){
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator(),);
                case ConnectionState.active:
                case ConnectionState.done:

                  final data = snapshot.data!.docs;
                 _list = data.map((e) => ChatModel.fromJson(e.data())).toList() ?? [];
                if(_list.isNotEmpty){
                  return ListView.builder(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*.01),
                    physics: BouncingScrollPhysics(),
                    itemCount: _isSearching ? _searchList.length :_list.length,
                    itemBuilder: (context, index) {
                      return
                        CardWidget(user: _isSearching ? _searchList[index] :_list[index],);
                    },);
                }
                else{
                  return Center(child: Text("No users found"));
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
