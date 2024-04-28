import 'dart:async';
import 'package:asaf/services/statics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

User? user = FirebaseAuth.instance.currentUser;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final navigatorKey = GlobalKey();

final userid = user;
// checkNotificationPersmission() {
//   AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//     if (!isAllowed) {
//       AwesomeNotifications().requestPermissionToSendNotifications();
//     } else {}
//   });
// }
onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() async {
  // AwesomeNotifications().initialize(null, [
  //   NotificationChannel(
  //       importance: NotificationImportance.High,
  //       enableVibration: true,
  //       playSound: true,
  //       channelKey: 'drivesense',
  //       channelName: 'Notification',
  //       channelDescription: "For app notifications")
  // ]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance();

  FirebaseFirestore.instance.settings =
      const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  final navigatorKey = GlobalKey<NavigatorState>();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(MyApp(navigatorKey: navigatorKey));
  });
}

void subscribeToTopic(String topic) {
  FirebaseMessaging.instance.subscribeToTopic(topic);

  print('Subscribed to topic: $topic');

  FirebaseFirestore.instance
      .collection('DriveSenseUsers')
      .doc(user!.uid)
      .collection('userData')
      .doc(user!.uid)
      .update({'userid': user!.uid});
}

@pragma('vn:entry-point')
Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  await Firebase.initializeApp();
  // AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //         id: 6444,
  //         channelKey: 'drivesense',
  //         title: message.notification!.title.toString(),
  //         body: message.notification!.title.toString(),
  //         category: NotificationCategory.Call,
  //         wakeUpScreen: true));
  print(message.notification!.title.toString());
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
    if (userid != null) {
      //onUserLogin();
      subscribeToTopic(user!.uid);
    }
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   setState(() {
  //     _appState = state.toString();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/images/loginback.jpeg'), context);
    precacheImage(AssetImage('assets/images/registerback.jpeg'), context);
    precacheImage(AssetImage('assets/images/lg.jpg'), context);
    precacheImage(AssetImage('assets/images/newuser1.jpg'), context);
    precacheImage(AssetImage('assets/images/logo.png'), context);
    return MaterialApp(
      routes: routes,
      initialRoute: PageRouteNames.login,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFEFEFEF)),
      navigatorKey: widget.navigatorKey,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            child!,
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return widget.navigatorKey.currentState!.context;
              },
            ),
            //ZegoCallAndroidNotificationConfig()
          ],
        );
      },
    );
  }
}
