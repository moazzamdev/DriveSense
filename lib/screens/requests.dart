import 'package:asaf/utils/constants.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

User? user = FirebaseAuth.instance.currentUser;

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<UserInfo> userInfos = [];
  Map<String, bool> copyStatus = {}; // To keep track of copied items

  @override
  void initState() {
    super.initState();
    fetchAllUserData();
  }

  Future<void> fetchAllUserData() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .doc(user!.uid)
          .collection('requests')
          .get();

      // Extracting user IDs from the QuerySnapshot
      List<dynamic> userIds =
          userSnapshot.docs.map((doc) => doc.get('userid')).toList();

      // Iterate through each reqid and fetch user data
      for (dynamic reqid in userIds) {
        if (reqid is String) {
          try {
            QuerySnapshot userDataSnapshot = await FirebaseFirestore.instance
                .collection('DriveSenseUsers')
                .doc(reqid)
                .collection('userData')
                .get();

            // Extract user data for the current reqid
            List<UserInfo> usersData = userDataSnapshot.docs.map((doc) {
              String vehiclenumber =
                  doc.get('vehiclenumber') ?? 'vehiclenumber';
              String userName = doc.get('fullname') ?? 'fullnamename';
              String userId = doc.id;
              String url =
                  doc.get('gprofileImageUrl'); // Use doc.id for the document ID

              return UserInfo(userId, vehiclenumber, userName, url);
            }).toList();

            setState(() {
              // Add the fetched user data to the existing userInfos list
              userInfos.addAll(usersData);
              // Initialize copyStatus for each user as false initially
              copyStatus = Map.fromIterable(userInfos,
                  key: (e) => e.userId, value: (_) => false);
            });
          } catch (e) {
            print("Error fetching user data: $e");
            // Handle the error here, such as displaying an error message to the user.
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle the error here, such as displaying an error message to the user.
    }
  }

  Future<void> deleteRequest(String userId) async {
    try {
      // Get the reference to the document to delete
      DocumentReference requestRef = FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .doc(user!.uid) // Document ID is the userId
          .collection('requests')
          .doc(userId); // Document ID is the userId

      // Delete the document
      await requestRef.delete();

      print('Document with userId $userId deleted successfully.');
    } catch (e) {
      print('Error deleting document: $e');
      // Handle the error here, such as displaying an error message to the user.
    }
  }

  Future<void> acceptRequest(String requestedUserId) async {
    try {
      // Step 1: Fetch the requested user data
      DocumentSnapshot requestedUserDataSnapshot = await FirebaseFirestore
          .instance
          .collection('DriveSenseUsers')
          .doc(requestedUserId)
          .collection('userData')
          .doc(requestedUserId)
          .get();

      // Extract requested user data
      String vehiclenumber =
          requestedUserDataSnapshot.get('vehiclenumber') ?? 'vehiclenumber';
      String userName =
          requestedUserDataSnapshot.get('fullname') ?? 'fullnamename';
      String userId = requestedUserDataSnapshot.id;
      String url = requestedUserDataSnapshot.get('gprofileImageUrl');
      String reqtoken = requestedUserDataSnapshot.get('device_token');
      // Update current user's contacts collection
      await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .doc(user!.uid)
          .collection('contacts')
          .doc(userId)
          .set({
        'vehiclenumber': vehiclenumber,
        'fullname': userName,
        'userid': userId,
        'gprofileImageUrl': url,
        'device_token': reqtoken
      });

      // Step 2: Fetch current user data
      DocumentSnapshot currentUserDataSnapshot =
          await FirebaseFirestore.instance
              .collection('DriveSenseUsers')
              .doc(user!.uid)
              .collection('userData') // Specify the collection name here
              .doc(user!.uid) // Assuming user ID is used as the document ID
              .get();

      // Extract current user data
      String currentUserVehiclenumber =
          currentUserDataSnapshot.get('vehiclenumber') ?? 'vehiclenumber';
      String currentUserName =
          currentUserDataSnapshot.get('fullname') ?? 'fullnamename';
      String currentUserId = user!.uid;
      String urll = currentUserDataSnapshot.get('gprofileImageUrl');
      String currtoken = currentUserDataSnapshot.get('device_token');

      // Update requested user's contacts collection
      await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .doc(requestedUserId)
          .collection('contacts')
          .doc(currentUserId)
          .set({
        'vehiclenumber': currentUserVehiclenumber,
        'fullname': currentUserName,
        'userid': currentUserId,
        'gprofileImageUrl': urll,
        'device_token': currtoken
      });

      // Step 3: Delete the request from current user's requests collection
      await FirebaseFirestore.instance
          .collection('DriveSenseUsers')
          .doc(user!.uid)
          .collection('requests')
          .doc(requestedUserId)
          .delete();
      pushNotificationsAllUsers(
          title: 'New Friend Request',
          body: '$currentUserVehiclenumber accepted your request',
          topicname: reqtoken);
      print('Request from user $requestedUserId accepted successfully.');
    } catch (e) {
      print('Error accepting request: $e');
      // Handle the error here, such as displaying an error message to the user.
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
              .collection('requests')
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

                return UserInfo(userId, vehiclenumber, userName, url);
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
                                "No Requests",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (int index = 0;
                                index < userInfos.length;
                                index++)
                              Card(
                                elevation: 2,
                                borderOnForeground: true,
                                surfaceTintColor: Colors.black,
                                color: Colors.white,
                                child: ListTile(
                                  onTap: () {
                                    print('Tapped user at index $index:');
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: userInfos[index].url !=
                                            'non'
                                        ? CachedNetworkImageProvider(
                                                userInfos[index].url)
                                            as ImageProvider
                                        : AssetImage(
                                                'assets/images/usericon.jpg')
                                            as ImageProvider,
                                  ),
                                  title: Text(
                                    userInfos[index].userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle:
                                      Text(userInfos[index].vehiclenumber),
                                  trailing: IntrinsicWidth(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            acceptRequest(
                                                userInfos[index].userId);
                                            Utils().errortoast(
                                                'You are now friends with ${userInfos[index].userName}',
                                                context);
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.green,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            deleteRequest(
                                                userInfos[index].userId);
                                            Utils().errortoast(
                                                'Request Deleted From ${userInfos[index].userName}',
                                                context);
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.red,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            // Show dialog with user info
                                            showDialog(
                                              //barrierColor: Colors.transparent,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.all(25),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 50,
                                                        backgroundImage: userInfos[
                                                                        index]
                                                                    .url !=
                                                                'non'
                                                            ? CachedNetworkImageProvider(
                                                                    userInfos[
                                                                            index]
                                                                        .url)
                                                                as ImageProvider
                                                            : AssetImage(
                                                                    'assets/images/usericon.jpg')
                                                                as ImageProvider,
                                                      ),
                                                      SizedBox(height: 20),
                                                      Text(
                                                        'User Info',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        '${userInfos[index].userName}\n'
                                                        '${userInfos[index].vehiclenumber}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(height: 20),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Close'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class UserInfo {
  final String userId;
  final String userName;
  final String vehiclenumber;
  final String url;

  UserInfo(this.userId, this.userName, this.vehiclenumber, this.url);
}

Future<bool> pushNotificationsAllUsers(
    {required String title,
    required String body,
    required String topicname}) async {
  String dataNotifications = '{ '
      ' "to" : "$topicname" , ' // Specify the topic to send notifications to all devices/users
      ' "notification" : {'
      ' "title":"$title" , '
      ' "body":"$body" '
      ' } '
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
