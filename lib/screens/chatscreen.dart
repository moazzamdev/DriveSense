import 'package:asaf/screens/contacts.dart';
import 'package:asaf/screens/requests.dart';
import 'package:asaf/utils/constants.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

User? user = FirebaseAuth.instance.currentUser;

String userid = user!.uid;

void onUserLogin() async {
  final userdoc = await FirebaseFirestore.instance
      .collection('DriveSenseUsers')
      .doc(userid)
      .collection('userData')
      .doc(userid)
      .get();
  final username = userdoc['vehiclenumber'];

  /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 586587609, // Input your AppID
    appSign: "61b675c59a4639aa1515f073c303093c9d73ece525be7cff7137500781a309f6",
    /*input your AppSign*/
    userID: userid,
    userName: '$username',
    appName: "DriveSense",
    showCancelInvitationButton: true,
    showDeclineButton: true,
    notifyWhenAppRunningInBackgroundOrQuit: true,
    androidNotificationConfig: ZegoAndroidNotificationConfig(
      channelID: "ZegoUIKit",
      channelName: "Call Notifications",
      sound: "notification",
      vibrate: true,
      icon: "Call",
    ),
    iOSNotificationConfig: ZegoIOSNotificationConfig(
      isSandboxEnvironment: false,
      systemCallingIconName: 'CallKitIcon',
    ),
    plugins: [ZegoUIKitSignalingPlugin()],
    requireConfig: (ZegoCallInvitationData data) {
      final config = (data.invitees.length > 1)
          ? ZegoCallType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
              : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
          : ZegoCallType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

      /// custom avatar
      config.avatarBuilder = customAvatarBuilder;

      /// support minimizing, show minimizing button
      config.topMenuBarConfig.isVisible = true;
      config.topMenuBarConfig.buttons
          .insert(0, ZegoMenuBarButtonName.minimizingButton);

      return config;
    },
  );
}

/// on user logout
void onUserLogout() {
  /// 5/5. de-initialization ZegoUIKitPrebuiltCallInvitationService when account is logged out
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController _userNameController = TextEditingController();

  Future<void> _addNewUser(BuildContext context) async {
    String? userName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Vehicle Number'),
          content: TextField(
            controller: _userNameController,
            decoration: InputDecoration(hintText: 'Vehicle Number'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                //triggernoti();

                Navigator.pop(context, _userNameController.text.toUpperCase());
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (userName != null) {
      // Search for user in Firestore
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .where('vehiclenumber', isEqualTo: userName)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var id = userQuery.docs.first.id;
        var reqname = userQuery.docs.first['vehiclenumber'];

        final userDoc = await FirebaseFirestore.instance
            .collection('DriveSenseUsers')
            .doc(user!.uid)
            .collection('userData')
            .doc(user!.uid)
            .get();

        final String name = userDoc['vehiclenumber'] ?? '';
        final String fullname = userDoc['fullname'] ?? '';
        final String url = userDoc['gprofileImageUrl'] ?? '';
        // Found user, update current user's collection

        FirebaseFirestore.instance
            .collection('DriveSenseUsers')
            .doc(id)
            .collection('requests')
            .doc(user!.uid)
            .set({
          'userid': user!.uid,
          'vehiclenumber': name,
          'gprofileImageUrl': url,
          'fullname': fullname
        });
        pushNotificationsAllUsers(
            title: "New Friend Request",
            body: "$name wants to be your friend",
            topicname: id);
        Utils().errortoast('Request Sent to $reqname', context);
      } else {
        // User not found
        Utils().errortoast('User not found', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    onUserLogin();

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.orange,
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: false,
              physics: ScrollPhysics(),
              labelColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Contacts',
                ),
                Tab(
                  text: 'Request',
                ),
              ],
            ),
            title: const Text(
              'Conversation',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  _addNewUser(context);
                  //Navigator.of(context).pop();
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.pink[50],
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.orange,
                        size: 15,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        "Add New",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          body: TabBarView(
            children: [UserData(), Requests()],
          ),
        ),
      ),
    );
  }
}

Future<bool> pushNotificationsAllUsers(
    {required String title,
    required String body,
    required String topicname}) async {
  String dataNotifications = '{ '
      ' "to" : "/topics/$topicname" , ' // Specify the topic to send notifications to all devices/users
      ' "notification" : {'
      ' "title":"$title" , '
      ' "body":"$body" ,'
      ' "notificationType":"call" '
      ' }, '
      '"priority": "high"'
      ' } ';

  var response = await http.post(
    Uri.parse(Constants.BASE_URL),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key= ${Constants.KEY_SERVER}',
    },
    body: dataNotifications,
  );
  print(response.body.toString());
  return true;
}
