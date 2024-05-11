import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/mydateutil.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/chatmodel.dart';

class UsersProfileScreen extends StatefulWidget {
  final ChatModel user;

  const UsersProfileScreen({super.key, required this.user});

  @override
  State<UsersProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UsersProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Profile view",style: TextStyle(color: Colors.blue),),
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height*.03),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 25),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12,blurRadius: 0.5,spreadRadius: 2)
                        ]),
                    child: ClipRRect(
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
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Name",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black54),),
                      Text(widget.user.name,style: TextStyle(color: Colors.black87,fontSize: 15),)
                    ],
                  )
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*.03,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email",style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.bold),),
                  Text(widget.user.email,style: TextStyle(fontSize: 15,color: Colors.black87),),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*.005,),
              Divider(thickness: 2,),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("About",style: TextStyle(fontSize: 16,color: Colors.white70,fontWeight: FontWeight.bold),),
                    Text(widget.user.about,style: TextStyle(fontSize: 15,color: Colors.white),),

                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Joined at:",style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.bold),),
                  Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showyear: true),style: TextStyle(fontSize: 15,color: Colors.black87),),
                ],
              )
            ],
          ),
        )
    );
  }
}
