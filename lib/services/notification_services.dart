import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:asaf/screens/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  bool isFlutterLocalNotificationsInitialized = false;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Permision granted');
    } else {
      print('not  granted');
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {});
  }

  void firebaseInit(BuildContext context) {
    //notigy();
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        //notigy();
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }
      if (Platform.isIOS) {
        foregroundMessage();
      }
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        //notigy();
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    //notigy();
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        'High Important Notification',
        importance: Importance.max);
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id.toString(),
            channel.name.toString(),
            channelDescription: 'my channel',
            icon: 'launch_background',
          ),
        ),
      );
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: "my channel",
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      //notigy();
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
      // AwesomeNotifications().createNotification(
      //     content: NotificationContent(
      //         id: 6444,
      //         channelKey: 'drivesense',
      //         title: message.notification!.title.toString(),
      //         body: message.notification!.body.toString(),
      //         category: NotificationCategory.Call,
      //         wakeUpScreen: true));
    });

    //notigy();
  }

  Future<String> getDeviceToken() async {
    messaging.getToken();
    String? token = await messaging.getToken();
    await FirebaseFirestore.instance
        .collection('DriveSenseUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'device_token': token});

    await FirebaseFirestore.instance
        .collection('DriveSenseUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'device_token': token});
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Refresh');
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'quiznotification') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatScreen()));
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    //notigy();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  Future foregroundMessage() async {
    //notigy();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }
}
