import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/mydateutil.dart';
import 'package:chat_app/models/chatmodel.dart';
import 'package:chat_app/screens/user_profile_Section.dart';
import 'package:chat_app/widgets/msg_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';
import '../models/usermodel.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  bool _showEmoji = false;
  bool _isUploading = false;
  List<ChatModel> list = [];
  var _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.blue.shade50,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: UserModel.getAllMsg(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasData) {
                          final data = snapshot.data!.docs;
                          _list = data
                                  .map((e) => MessageModel.fromJson(e.data()))
                                  .toList() ??
                              [];
                        }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .01),
                            physics: BouncingScrollPhysics(),
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              return MessageCard(
                                message: _list[index],
                              );
                            },
                          );
                        } else {
                          return Center(
                              child: Text(
                            "Say Hi! 👋",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ));
                        }
                    }
                  },
                ),
              ),
              if(_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  ),
                ),
              _chatInput(),

              if (_showEmoji)
                SizedBox(
                  height: MediaQuery.of(context).size.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(
                      backspaceColor: Colors.blue,
                      bgColor: Colors.blue.shade50,
                      columns: 8,
                      emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UsersProfileScreen(user: widget.user),));
        },
        child: StreamBuilder(
          stream: UserModel.getLastOnlineStatus(widget.user),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              final data = snapshot.data!.docs;
              final list = data.map((e) => ChatModel.fromJson(e.data())).toList() ?? [];
            }
             return Row(children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black45,
                ),
              ),
              ClipRRect(
                borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.height * .1),
                child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width * .12,
                    height: MediaQuery.of(context).size.height * .06,
                    imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        CupertinoIcons.person,
                        color: Colors.white,
                      ),
                    )),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.isNotEmpty ? list[0].name:
                    widget.user.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    list.isNotEmpty ?
                    list[0].isOnline ? "Online" :
                    MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: TextStyle(
                        fontSize: 12, color: Colors.black.withOpacity(0.5)),
                  ),
                ],
              )
            ]);
          },
        )
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .03,
          vertical: MediaQuery.of(context).size.height * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blue,
                      )),
                  Expanded(
                      child: TextField(
                    onTap: () {
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: "Type Something...",
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage();
                        for (var i in images){
                          setState(() {
                            _isUploading = true;
                          });
                         await UserModel.sendChatImage(widget.user, File(i.path)).then((value){
                           setState(() {
                             _isUploading = false;
                           });
                         });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blue,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          await UserModel.sendChatImage(widget.user,File(image.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera,
                        color: Colors.blue,
                      ))
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                UserModel.sendMsg(widget.user, _textController.text, Type.text);
                _textController.text = "";
              }
            },
            shape: CircleBorder(),
            color: Colors.green,
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, right: 5, bottom: 10, left: 10),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
