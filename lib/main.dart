
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';

late Size scr_size;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,DeviceOrientation.portraitDown
  ]).then((value) async{

    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCmC1wXN9qKWQ7Y-Q7qJCTOyqF1k6mVEV0",
            appId: "1:924848308678:android:0a85bea597f110ea9572c7",
            messagingSenderId: "924848308678",
            projectId: "kbc-791a4" ,
            storageBucket: "kbc-791a4.appspot.com"
        ),

    );
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Chatify',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          elevation: 5,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black
          )
        ),
        primarySwatch: Colors.deepPurple
      ),
      home: SplashScreen(),
    );
  }
}

_createChannel()async{

  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'for notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chat',

  );
  print(result);
}