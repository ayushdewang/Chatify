import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/mydateutil.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/dialog.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key,required this.message});
  final MessageModel message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = FirebaseAuth.instance.currentUser!.uid == widget.message.fromId;
    return InkWell(
      onLongPress: (){
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMsg() : _blueMsg(),
    );

  }
  Widget _blueMsg(){

    if(widget.message.read.isEmpty){
      UserModel.updateMessageReadStatus(widget.message);
      log("Message read updated");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.04,vertical: MediaQuery.of(context).size.height*.01),
            decoration: BoxDecoration(
              borderRadius: widget.message.type == Type.image ?
                  BorderRadius.circular(5)
                  :
              BorderRadius.only(topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
                bottomRight: Radius.circular(30)
              ),
              border: Border.all(color: Colors.lightBlueAccent),
              color: Colors.blue.shade50
            ),
            padding: EdgeInsets.all(widget.message.type == Type.image ? 0 :MediaQuery.of(context).size.width*.04),
            child:
            widget.message.type == Type.text ?
            Text(widget.message.msg,style: TextStyle(fontSize: 17),) :
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.image,color: Colors.white,),
                  )
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*.04),
          child: Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),style: TextStyle(fontSize: 13,color: Colors.black45),),
        )
      ],
    );
  }
  Widget _greenMsg(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*.04,),
            if (widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded,size: 15,color: Colors.blue,),
            SizedBox(width: 2,),
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),style: TextStyle(fontSize: 13,color: Colors.black45),),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.04,vertical: MediaQuery.of(context).size.height*.01),
            decoration: BoxDecoration(
                borderRadius: widget.message.type == Type.image ? 
                 BorderRadius.circular(5)
                    :
                BorderRadius.only(topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)
                ),
                border: Border.all(color: Colors.lightGreenAccent),
                color: Colors.green.shade50
            ),
            padding: EdgeInsets.all(widget.message.type == Type.image ? 0 :MediaQuery.of(context).size.width*.04),
            child: widget.message.type == Type.text ?
            Text(widget.message.msg,style: TextStyle(fontSize: 17),) :
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: widget.message.msg,
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.image,color: Colors.white,),
                  )
              ),
            ),),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        context: context, builder: (_){
      return ListView(
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.4),
            child: Divider(color: Colors.grey,thickness: 2,),
          ),
          widget.message.type == Type.text ?
          _optionItem(icon: Icon(Icons.copy_all_rounded,color: Colors.blue,size: 25,), name: "Copy Text",
              ontap: ()async{
            await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){
              Navigator.pop(context);
              // Dialogs.showSnackbar(context,"Text Copied!");
            } );
              })
          :
          _optionItem(icon: Icon(Icons.download_for_offline_rounded,color: Colors.blue,size: 25,), name: "Save Image", ontap: (){}),
          if(widget.message.type == Type.text && isMe)
          _optionItem(icon: Icon(Icons.edit,color: Colors.blue,size: 25,), name: "Edit Message",
              ontap: (){
            Navigator.pop(context);
            _showMessageUpdateDialog();

              }),
          if(isMe)
          _optionItem(icon: Icon(Icons.delete_forever,color: Colors.red,size: 25,), name: "Delete",
              ontap: ()async{
            await UserModel.deleteMessage(widget.message).then((value){
              Navigator.pop(context);
            });
              }),
          Divider(color: Colors.black26,endIndent: 20,indent: 20,),
          _optionItem(
              icon: Icon(Icons.remove_red_eye,color: Colors.blue,size: 25,),
              name: "Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
              ontap: (){}),
          _optionItem(icon: Icon(Icons.remove_red_eye,color: Colors.green,size: 25,),
              name: widget.message.read.isEmpty ? " Read At: Not seen yet" :
              "Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
              ontap: (){}),
        ],
      );
    });
  }
  void _showMessageUpdateDialog(){
    String updatedMsg = widget.message.msg;

    showDialog(context: context, builder: (_) => AlertDialog(
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Update Message",style: TextStyle(fontSize: 18),),
            Icon(Icons.message,color: Colors.blue,size: 25,)
          ]),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: TextFormField(
          initialValue: updatedMsg,
        maxLines: null,
        onChanged: (value) => updatedMsg = value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16),),),
        MaterialButton(onPressed: ()async{
          await UserModel.updateMessage(widget.message, updatedMsg).then((value){
            Navigator.pop(context);
          });
        },child: Text("Update",style: TextStyle(color: Colors.blue,fontSize: 16),),)
      ]
    ));

  }
}


class _optionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback ontap;
  const _optionItem({required this.icon,required this.name,required this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: ()=> ontap(),
      child: Padding(
        padding: EdgeInsets.only(left: 20,top: 10,bottom: 15),
        child: Row(children: [icon,Flexible(child: Text("   $name",style: TextStyle(fontSize: 16,color: Colors.black54,letterSpacing: 0.5),))],),
      ),
    );
  }
}

