import 'package:asaf/screens/streaming.dart';
import 'package:asaf/services/notification_services.dart';
import 'package:asaf/utils/constants.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

User? user = FirebaseAuth.instance.currentUser;
String imageurl = "";
List<String> urls = [];

class UserData extends StatefulWidget {
  const UserData({Key? key}) : super(key: key);

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
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
                Navigator.pop(context, _userNameController.text.toUpperCase());
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (userName != null) {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .where('vehiclenumber', isEqualTo: userName)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var id = userQuery.docs.first.id;
        var name = userQuery.docs.first['vehiclenumber'];

        FirebaseFirestore.instance
            .collection('DriveSenseUsers')
            .doc(id)
            .collection('requests')
            .doc(user!.uid)
            .set({'userid': user!.uid});
        pushNotificationsAllUsers(
            title: "New Friend Request",
            body: "$name wants to be your friend",
            topicname: id);
        Utils().errortoast('Request Sent', context);
      } else {
        Utils().errortoast('User not found', context);
      }
    }
  }

  List<UserInfo> userInfos = [];
  NotificationServices notificationServices = NotificationServices();
  Map<String, bool> copyStatus = {};

  @override
  void initState() {
    super.initState();
    fetchAllUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchAllUserData() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .doc(user!.uid)
          .collection('contacts')
          .get();

      List<UserInfo> usersData = userSnapshot.docs.map((doc) {
        String vehiclenumber = doc.get('vehiclenumber') ?? 'vehiclenumber';
        String userName = doc.get('fullname') ?? 'fullnamename';
        String userId = doc.get('userid');
        String url = doc.get('gprofileImageUrl');
        final token = doc.get('device_token');
        urls.add(url);
        return UserInfo(userId, vehiclenumber, userName, url, token);
      }).toList();

      setState(() {
        userInfos = usersData;
        copyStatus = Map.fromIterable(userInfos,
            key: (e) => e.userId, value: (_) => false);
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('DriveSenseUsers')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('contacts')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final userInfos = snapshot.data!.docs.map((doc) {
                final vehiclenumber =
                    doc.get('vehiclenumber') ?? 'vehiclenumber';
                final userName = doc.get('fullname') ?? 'fullnamename';
                final userId = doc.id;
                final url = doc.get('gprofileImageUrl');
                final token = doc.get('device_token');
                return UserInfo(userId, vehiclenumber, userName, url, token);
              }).toList();

              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: userInfos.isEmpty
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "No Contacts?",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: userInfos.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 12);
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 5,
                              borderOnForeground: true,
                              surfaceTintColor: Colors.black,
                              color: Colors.white,
                              child: ListTile(
                                onTap: () {
                                  print('Tapped user at index $index:');
                                },
                                leading: CircleAvatar(
                                  backgroundImage: userInfos[index].userimage !=
                                          'non'
                                      ? CachedNetworkImageProvider(
                                              userInfos[index].userimage)
                                          as ImageProvider
                                      : AssetImage('assets/images/usericon.jpg')
                                          as ImageProvider,
                                ),
                                title: Text(
                                  userInfos[index].userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(userInfos[index].vehiclenumber),
                                trailing: IntrinsicWidth(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: actionbutton(
                                            false,
                                            userInfos[index].userId,
                                            userInfos[index].userName,
                                            userInfos[index].userimage,
                                            index),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Delete Contact'),
                                                content: Text(
                                                    'Are you sure to delete ${userInfos[index].userName}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Utils().errortoast(
                                                          '${userInfos[index].userName} has been deleted',
                                                          context);
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'DriveSenseUsers')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .collection(
                                                              'contacts')
                                                          .doc(userInfos[index]
                                                              .userId)
                                                          .delete();
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'DriveSenseUsers')
                                                          .doc(userInfos[index]
                                                              .userId)
                                                          .collection(
                                                              'contacts')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .delete();
                                                    },
                                                    child: Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          pushNotificationsAllUsers(
                                              title: 'Room Invitation',
                                              body:
                                                  '${userInfos[index].userName} is inviting you to join a room',
                                              topicname:
                                                  userInfos[index].token);
                                          print(userInfos[index].token);
                                          await FirebaseFirestore.instance
                                              .collection('DriveSenseUsers')
                                              .doc(userInfos[index].userId)
                                              .update({
                                            'room_invitor': FirebaseAuth
                                                .instance.currentUser!.uid
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('DriveSenseUsers')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            'room_invitor': FirebaseAuth
                                                .instance.currentUser!.uid
                                          });
                                          DatabaseReference reference =
                                              FirebaseDatabase.instance.ref();

                                          reference
                                              .child('music_room')
                                              .child(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .child('Listener')
                                              .set({
                                            'imageurl':
                                                userInfos[index].userimage,
                                            'vehicle_number':
                                                userInfos[index].userName,
                                            'joined': 'false',
                                          });

                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                          final cachedregno = prefs
                                                  .getString('vehiclenumber') ??
                                              '';
                                          final cachedimageurl =
                                              prefs.getString(
                                                      'gprofileImageUrl') ??
                                                  '';
                                          DatabaseReference referencee =
                                              FirebaseDatabase.instance.ref();

                                          referencee
                                              .child('music_room')
                                              .child(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .child('Author')
                                              .update({
                                            'imageurl': cachedimageurl,
                                            'vehicle_number': cachedregno,
                                            'joined': 'true',
                                          });

                                          referencee
                                              .child('music_room')
                                              .child(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            'total_users': 1,
                                            'room_creator': FirebaseAuth
                                                .instance.currentUser!.uid,
                                            'author': 'true'
                                          });

                                          reference
                                              .child('music_room')
                                              .child(userInfos[index].userId)
                                              .child('Listener')
                                              .set({
                                            'imageurl':
                                                userInfos[index].userimage,
                                            'vehicle_number':
                                                userInfos[index].userName,
                                            'joined': 'false',
                                          });

                                          referencee
                                              .child('music_room')
                                              .child(userInfos[index].userId)
                                              .child('Author')
                                              .update({
                                            'imageurl': cachedimageurl,
                                            'vehicle_number': cachedregno,
                                            'joined': 'true',
                                          });
                                          referencee
                                              .child('music_room')
                                              .child(userInfos[index].userId)
                                              .update({
                                            'total_users': 1,
                                            'room_creator': FirebaseAuth
                                                .instance.currentUser!.uid,
                                            'author': 'false'
                                          });

                                          // pushNotificationsAllUsers(
                                          //     title: 'Room Inivation',
                                          //     body:
                                          //         '${userInfos[index].userName} is inviting you to join a room',
                                          //     topicname:
                                          //         userInfos[index].token);

                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return const StreamingScreen();
                                              },
                                            ),
                                            (_) => false,
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Icon(Icons.broadcast_on_home,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  ZegoSendCallInvitationButton actionbutton(
      bool isVideo, String idd, String namee, String url, int index) {
    if (url != 'non') {
      //imageurl = urls[index];
      print(imageurl);
    }

    return ZegoSendCallInvitationButton(
      invitees: [ZegoUIKitUser(id: idd, name: namee)],
      isVideoCall: isVideo,
      resourceID: "zego_data",
      iconSize: const Size(40, 40),
      buttonSize: const Size(80, 80),
    );
  }
}

class UserInfo {
  final String userId;
  final String userName;
  final String vehiclenumber;
  final String userimage;
  final String token;

  UserInfo(this.userId, this.userName, this.vehiclenumber, this.userimage,
      this.token);
}

Widget customAvatarBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  return CachedNetworkImage(
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/my-esp32-project-1c6a6.appspot.com/o/images%2Fusericon.jpg?alt=media&token=a3c2a4ab-dfb6-40cf-b60a-524658bdf314",
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (context, url, error) {
      ZegoLoggerService.logInfo('$user avatar url is invalid',
          tag: 'live audio', subTag: 'live page');
      return ZegoAvatar(user: user, avatarSize: size);
    },
  );
}

Future<bool> pushNotificationsAllUsers(
    {required String title,
    required String body,
    required String topicname}) async {
  String dataNotifications = '{ '
      ' "to" : "$topicname" , '
      ' "notification" : {'
      ' "title":"$title" , '
      ' "body":"$body" ,'
      ' "notificationType":"message" '
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
