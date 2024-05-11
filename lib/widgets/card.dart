
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/mydateutil.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/widgets/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chatmodel.dart';
import '../screens/chat.dart';

class CardWidget extends StatefulWidget {
  final ChatModel user;
  const CardWidget({super.key,required this.user});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width *.03,vertical: 4),
      child: StreamBuilder(
          stream: UserModel.getLastMsg(widget.user),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              final data = snapshot.data!.docs;
              final list = data.map((e) => MessageModel.fromJson(e.data())).toList() ?? [];
              if(list.isNotEmpty){
                _message = list[0];
              }
            }

            return ListTile(
              tileColor: Colors.white,
              splashColor: Colors.blue.shade50,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user,),));
              },
              title: Text(widget.user.name),
              subtitle: Text(_message != null ? _message!.type == Type.image ? "image" : _message!.msg : widget.user.about,maxLines: 1,),
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (context) => ShowProfile(user: widget.user),);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
                  child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width *.12,
                      height: MediaQuery.of(context).size.height *.06,
                      imageUrl: widget.user.image,
                      //placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(CupertinoIcons.person,color: Colors.white,),
                      )
                  ),
                ),
              ),
              trailing: _message == null ? Text("") : 
              _message!.read.isEmpty && _message!.fromId != FirebaseAuth.instance.currentUser!.uid?
              Icon(Icons.circle,color: Colors.green.shade400,size: 20,) :
                  Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent))
            );
          },)
    );
  }
}
