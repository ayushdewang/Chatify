import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/user_profile_Section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/chatmodel.dart';

class ShowProfile extends StatefulWidget {
  final ChatModel user;
  const ShowProfile({super.key,required this.user});

  @override
  State<ShowProfile> createState() => _ShowProfileState();
}

class _ShowProfileState extends State<ShowProfile> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      content: Stack(
        children: [
          Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              child: CachedNetworkImage(
                  // width: MediaQuery.of(context).size.width *.5,
                  imageUrl: widget.user.image,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(CupertinoIcons.person,color: Colors.white,),
                  ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                IconButton(onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user),));
                }, icon: Icon(Icons.chat,color: Colors.white,size: 30,)),
                IconButton(onPressed: (){}, icon: Icon(Icons.call,color: Colors.white,size: 30,)),
                IconButton(onPressed: (){}, icon: Icon(Icons.video_call,color: Colors.white,size: 35,)),
                IconButton(onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UsersProfileScreen(user: widget.user),));
                }, icon: Icon(Icons.info,color: Colors.white,size: 30,)),
              ],),
            )
          ],
        ),
          Positioned(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*.05,
                color: Colors.black12,
                child: Text(widget.user.name,style: TextStyle(color: Colors.white,fontSize: 19),),
              )),
        ]
      ),
    );
  }
}
