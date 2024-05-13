import 'dart:async';
import 'package:asaf/services/statics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:asaf/services/notification_services.dart';

User? user = FirebaseAuth.instance.currentUser;
final telephony = Telephony.instance;
NotificationServices notificationServices = NotificationServices();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final navigatorKey = GlobalKey();

final userid = user;
checkNotificationPersmission() {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    } else {}
  });
}

// void backgroundFetchHeadlessTask() async {
//   //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);

//   //notificationServices.foregroundMessage();

//   telephony.listenIncomingSms(
//       listenInBackground: true,
//       onBackgroundMessage: onBackgroundMessage,
//       onNewMessage: (SmsMessage message) {
//         AwesomeNotifications().createNotification(
//             content: NotificationContent(
//                 id: 6444,
//                 channelKey: 'drivesense',
//                 title: 'Message Received',
//                 body: 'This is message test notification',
//                 category: NotificationCategory.Message,
//                 wakeUpScreen: true));
//       });

//   BackgroundFetch.finish('taskId');
// }

// initBackgroundFetch() {
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
//   BackgroundFetch.configure(
//     BackgroundFetchConfig(
//       minimumFetchInterval: 15, // Minimum interval in minutes
//       stopOnTerminate:
//           false, // Continue background task even if app is terminated
//       enableHeadless: true,
//       startOnBoot: true,
//     ),
//     backgroundFetchHeadlessTask,
//     //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
//   );
//   BackgroundFetch.scheduleTask(
//     TaskConfig(
//       taskId: 'com.example.backgroundFetch',
//       delay: 10, // Delay task by 10 seconds (for testing purposes)
//       periodic: true, // Task repeats periodically
//       forceAlarmManager: true,
//     ),
//   );
//   backgroundFetchHeadlessTask;
// }

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 6444,
          channelKey: 'drivesense',
          title: 'Message Received',
          body: 'This is message test notification',
          category: NotificationCategory.Message,
          wakeUpScreen: true));
}

void main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        importance: NotificationImportance.High,
        enableVibration: true,
        playSound: true,
        channelKey: 'drivesense',
        channelName: 'Notification',
        channelDescription: "For app notifications")
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance();

  //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

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
  NotificationServices notificationServices = NotificationServices();
  
    notificationServices.foregroundMessage();
    notificationServices.getDeviceToken();
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);

//   //notificationServices.foregroundMessage(); 
    
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');

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

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _message = "";
  final telephony = Telephony.instance;
  String _appstate = '';
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    notificationServices.setupInteractMessage(context);
    notificationServices.firebaseInit(context);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    if (userid != null) {
      //onUserLogin();
      initPlatformState();
      //initBackgroundFetch();

      subscribeToTopic(user!.uid);
    }
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
      print(_message);
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 6444,
              channelKey: 'drivesense',
              title: 'Message Received',
              body: 'This is message test notification',
              category: NotificationCategory.Message,
              wakeUpScreen: true));
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      // Listen to incoming messages in the foreground
      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          listenInBackground: true,
          onBackgroundMessage: onBackgroundMessage);
      // Setup background message handling
      telephony.listenIncomingSms(
          onBackgroundMessage: onBackgroundMessage,
          listenInBackground: true,
          onNewMessage: onMessage);
    }

    if (!mounted) return;
  }

  // This method is called when a message is received in the background

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appstate = state.toString();
    });
  }

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
