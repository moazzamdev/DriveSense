// import 'package:asaf/main.dart';
// import 'package:flutter/material.dart';
// import 'package:telephony/telephony.dart';

// class SmsPage extends StatefulWidget {
//   @override
//   _SmsPageState createState() => _SmsPageState();
// }

// class _SmsPageState extends State<SmsPage> {
//   final telephony = Telephony.instance;
//   late String _message = '';

//   onMessage(SmsMessage message) async {
//     setState(() {
//       _message = message.body ?? "Error reading message body.";
//     });
//   }

//   void permission() async {
//     bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
//     if (permissionsGranted == true) {
//       print('granted');
//       telephony.listenIncomingSms(
//           onNewMessage: onMessage,
//           listenInBackground: true,
//           onBackgroundMessage: onBackgroundMessage);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     permission();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text("ESP32 Control"),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () =>
//                     telephony.sendSms(to: '923458313317', message: 'ON'),
//                 child: Text("Turn ON"),
//               ),
//               ElevatedButton(
//                 onPressed: () =>
//                     telephony.sendSms(to: '923458313317', message: 'OFF'),
//                 child: Text("Turn OFF"),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Incoming Message: $_message',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(SmsPage());
}

class SmsPage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<SmsPage> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Latest received SMS: $_message")),
          TextButton(
              onPressed: () async {
                await telephony.openDialer("123413453");
              },
              child: Text('Open Dialer'))
        ],
      ),
    ));
  }
}
