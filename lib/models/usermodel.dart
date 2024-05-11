import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/chatmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message.dart';
import 'package:http/http.dart' as http;

class UserModel {
  static Future<bool> userExist() async {
    return (await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get())
        .exists;
  }

  static late ChatModel me;
  static Future<void> getSelfInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatModel.fromJson(user.data()!);
        getFirebaseMessagingToken();
        await UserModel.updateActiveStatus(true);
      } else {
        createUser().then((value) => {getSelfInfo()});
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatModel(
        image: FirebaseAuth.instance.currentUser!.photoURL.toString(),
        about: "Hey, there I'm using Chatify",
        name: FirebaseAuth.instance.currentUser!.displayName.toString(),
        createdAt: time,
        id: FirebaseAuth.instance.currentUser!.uid,
        lastActive: time,
        isOnline: false,
        pushToken: "",
        email: FirebaseAuth.instance.currentUser!.email.toString());
    return (await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(chatUser.toJson()));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection("users")
        .where('id', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfile(File file) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance.ref().child(
        'profile_pictures/${FirebaseAuth.instance.currentUser!.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("data transferred: ${p0.bytesTransferred / 1000} kb");
    });
    me.image = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'image': me.image,
    });
  }

  static String getConversationID(String id) =>
      FirebaseAuth.instance.currentUser!.uid.hashCode <= id.hashCode
          ? '${FirebaseAuth.instance.currentUser!.uid}_$id'
          : '${id}_${FirebaseAuth.instance.currentUser!.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMsg(ChatModel user) {
    return FirebaseFirestore.instance
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMsg(ChatModel chatuser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final MessageModel message = MessageModel(
        toId: chatuser.id,
        msg: msg,
        read: "",
        type: type,
        fromId: FirebaseAuth.instance.currentUser!.uid,
        sent: time);
    final ref = FirebaseFirestore.instance
        .collection("chats/${getConversationID(chatuser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatuser, type == Type.text ? msg : "image"));
  }

  static Future<void> updateMessageReadStatus(MessageModel message) async {
    FirebaseFirestore.instance
        .collection("chats/${getConversationID(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(
      ChatModel user) {
    return FirebaseFirestore.instance
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatModel chatuser, File file) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance.ref().child(
        'images/${getConversationID(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("data transferred: ${p0.bytesTransferred / 1000} kb");
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMsg(chatuser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastOnlineStatus(
      ChatModel user) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: user.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static Future<void> getFirebaseMessagingToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await messaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log("push token ${value}");
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> sendPushNotification(ChatModel user, String msg) async {
    try{
      final body = {
        "to": user.pushToken,
        "notification": {"title": user.name, "body": msg,"android_channel_id": "chats",},
        "data": {
          "some_data" : "User ID: ${me.id}",
        },
      };
      var url = Uri.https("https://fcm.googleapis.com/fcm/send");
      var response = await http.post(url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAA11VBQcY:APA91bHV1aI8CCjKW8XzsBlFTBHnXRYNHJ3_-dfCE7NqYUi7KBLC3m7UWbG5J0IOJ3lvxP2g5vn3BVXLzLGi1bnk3XNbeuCPHRLXU2x1BrM96-QCO-HsC0NdZYrRUpwPlN8Odjq0xHyh'
          },
          body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    catch(e){
      log("sendNotificationError: $e");
    }
  }

  static Future<void> deleteMessage(MessageModel message)async{

    await FirebaseFirestore.instance
        .collection("chats/${getConversationID(message.toId)}/messages/")
        .doc(message.sent).delete();
    if(message.type == Type.image){

    await FirebaseStorage.instance.refFromURL(message.msg).delete();
    }
  }
  static Future<void> updateMessage(MessageModel message,String updatedMsg)async{

    await FirebaseFirestore.instance
        .collection("chats/${getConversationID(message.toId)}/messages/")
        .doc(message.sent).update({
      "msg": updatedMsg
    });

  }
}
