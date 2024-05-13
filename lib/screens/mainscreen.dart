import 'dart:async';
import 'package:asaf/main.dart';
import 'package:asaf/screens/chatscreen.dart';
import 'package:asaf/screens/live_tracking.dart';
import 'package:asaf/screens/location_history.dart';
import 'package:asaf/screens/speed.dart';
import 'package:asaf/screens/streaming.dart';
import 'package:asaf/services/notification_services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NotificationServices notificationServices = NotificationServices();
  @override
  // bool isOn = false;
  bool _showtracking = false;
  bool invited = false;
  String name = '';
  bool _showhistory = false;
  bool _showspeed = false;
  String greeting = '';
  String imageAsset = '';
  String ownername = '';
  String vehcile_reg_no = '';
  String vehicletype = '';
  String vehicle_name = '';
  String invitor_id = '';
  String imageurll = '';
  var speed;
  double speedd = 0.0;
  String selectedSpeedLimit = '100';
  var id;
  int limitt = 0;
  int speeed = 0;
  void listenForSpeedUpdates() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('speed')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          speed = event.snapshot.value;
          if (speed != 0) {
            var kph = speed * 3.6;
            speedd = kph;
            var rounded = kph.round();
            speed = rounded;
            speeed = speed;
            print(speeed);
            if (speed > limitt) {
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                    backgroundColor: Colors.white,
                    id: 6444,
                    channelKey: 'drivesense',
                    title: 'Speed Limit',
                    body: 'Your Speed Limit is exceeding',
                    category: NotificationCategory.Call,
                    wakeUpScreen: true,
                    duration: Durations.extralong1),
                actionButtons: [
                  NotificationActionButton(
                      key: 'ACTION_OK',
                      label: 'Dismiss',
                      actionType: ActionType
                          .DisabledAction // Payload to identify the action
                      ),
                ],
              );
            }
          }
        });
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }

  void listenForSpeedlimit() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('speed_limit')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          var limit = event.snapshot.value;
          if (limit != null) {
            selectedSpeedLimit = limit.toString();
            if (selectedSpeedLimit == '100') {
              setState(() {
                limitt = 100;
                print(limitt);
              });
            }
            if (selectedSpeedLimit == '120') {
              setState(() {
                limitt = 120;
              });
            }
            if (selectedSpeedLimit == '150') {
              setState(() {
                limitt = 150;
              });
            }
            if (selectedSpeedLimit == '50') {
              setState(() {
                limitt = 50;
                print(limitt);
              });
            }
            if (selectedSpeedLimit == '80') {
              setState(() {
                limitt = 80;
              });
            }
          }
        });
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }

  void listenForInvitations() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('author')
        .onValue
        .listen((event) {
      if (event.snapshot.exists &&
          event.snapshot.value != null &&
          event.snapshot.value.toString() == 'false') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Join Room?"),
              content: Text("Do you want to join the room?"),
              actions: <Widget>[
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    reference
                        .child('music_room')
                        .child(invitor_id)
                        .child('Listener')
                        .update({'joined': 'true'});

                    reference
                        .child('music_room')
                        .child(invitor_id)
                        .update({'total_users': 2});

                    reference
                        .child('music_room')
                        .child(FirebaseAuth.instance.currentUser!.uid)
                        .child('Listener')
                        .update({'joined': 'true'});

                    reference
                        .child('music_room')
                        .child(FirebaseAuth.instance.currentUser!.uid)
                        .update({'total_users': 2});
                    Navigator.of(context).pop();
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const StreamingScreen();
                        },
                      ),
                      (_) => false,
                    );
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }

  listenForMagnitude() async {
    final DatabaseReference controlCommandRef =
        FirebaseDatabase.instance.ref().child("device/magnitude");

    controlCommandRef.onValue.listen((event) {
      setState(() {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              backgroundColor: Colors.white,
              id: 6444,
              channelKey: 'drivesense',
              title: 'Hit Detected',
              body: 'Hit detected',
              category: NotificationCategory.Message,
              wakeUpScreen: true,
              duration: Durations.extralong1),
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    updateTime();
    getInvitorId();
    listenForInvitations();
    fetchUserName();
    listenForSpeedlimit();
    listenForSpeedUpdates();
    onUserLogin();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.foregroundMessage();
    notificationServices.getDeviceToken();
    notificationServices.setupInteractMessage(context);
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.settings = Settings(persistenceEnabled: true);
  }

  void updateTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      // Morning
      setState(() {
        greeting = 'Good Morning';
        imageAsset = 'assets/images/sun.png'; // Use your morning sun image
        // containerColor = Colors.blue; // Adjust color accordingly
      });
    } else if (hour >= 12 && hour < 18) {
      // Afternoon
      setState(() {
        greeting = 'Good Afternoon';
        imageAsset = 'assets/images/sun.png'; // Use your afternoon sun image
        // containerColor = Colors.orange; // Adjust color accordingly
      });
    } else {
      // Evening/Night
      setState(() {
        greeting = 'Good Evening';
        imageAsset =
            'assets/images/moon.png'; // Use your evening/night moon image
        // containerColor = Colors.indigo; // Adjust color accordingly
      });
    }
  }

  void getInvitorId() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('DriveSenseUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    userRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String idd = snapshot.get('room_invitor') ?? '';
        setState(() {
          invitor_id = idd;
          print(invitor_id);
        });
      }
    });
  }

  Future<void> fetchUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final cachedUserName = prefs.getString('userName') ?? '';
      final cachedowner = prefs.getString('vehicleowner') ?? '';
      final cachedvehicletype = prefs.getString('vehicletype') ?? '';
      final cachedregno = prefs.getString('vehiclenumber') ?? '';
      final cachedvehiclename = prefs.getString('vehiclename') ?? '';
      final cachedimageurl = prefs.getString('gprofileImageUrl') ?? '';
      if (cachedUserName.isNotEmpty) {
        setState(() {
          name = cachedUserName;
          ownername = cachedowner;
          vehicle_name = cachedvehiclename;
          vehicletype = cachedvehicletype;
          vehcile_reg_no = cachedregno;
          imageurll = cachedimageurl;
        });
        return;
      }
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the reference to the user document
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('DriveSenseUsers')
            .doc(user.uid)
            .collection('userData')
            .doc(user.uid);

        // Create a snapshot listener for real-time updates
        userRef.snapshots().listen((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            String userName = snapshot.get('fullname');
            String owner = snapshot.get('vehicleowner');
            String vehicle_type = snapshot.get('vehicletype');
            String vehiclename = snapshot.get('vehiclename');
            String vehcilereg_no = snapshot.get('vehiclenumber');
            String imageurl = snapshot.get('gprofileImageUrl');

            setState(() {
              name = userName;
              ownername = owner;
              vehicletype = vehicle_type;
              vehcile_reg_no = vehcilereg_no;
              vehicle_name = vehiclename;
              imageurll = imageurl;

              // Cache the fetched name
              prefs.setString('userName', userName);
              prefs.setString('vehicleowner', ownername);
              prefs.setString('vehicletype', vehicle_type);
              prefs.setString('vehiclenumber', vehcilereg_no);
              prefs.setString('vehiclename', vehiclename);
              prefs.setString('gprofileImageUrl', imageurl);
            });
          } else {
            print('User document does not exist');
          }
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
      // Handle the error here, such as displaying an error message to the user.
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        height: 120.0,
                        width: double.infinity,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      greeting,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      "$name",
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.grey),
                                    ),
                                    //SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              Spacer(), // Adds spacing between the text and the image
                              Container(
                                child: imageAsset.isNotEmpty
                                    ? Image.asset(
                                        imageAsset,
                                        width: 90,
                                        height: 90,
                                      )
                                    : Container(), // Display image only when imageAsset is not empty
                              ),
                            ]),
                      ),
                      Lottie.asset(
                        'assets/images/main.json',
                        repeat: false, width: 300, //height: 300
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     Padding(
                      //       padding: EdgeInsets.only(
                      //           left: 30,
                      //           bottom: 150), // Adjust left padding as needed
                      //       child: Text(
                      //         speed != null ? '${speed} KM/h' : '0 KM/h',
                      //         style: TextStyle(color: Colors.grey, fontSize: 20),
                      //       ),
                      //     ),
                      //     PowerButton(),
                      //   ],
                      // ),
                      PowerButton(),
                    ]),
                    //  Column(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         PowerButton(),
                    //       ],
                    //     ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(
                              0.5), // Background color with opacity
                          borderRadius: BorderRadius.circular(
                              8.0), // Optional: Border radius for rounded corners
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.navigation_sharp,
                                  color: Colors.black,
                                  size: 22.0,
                                ),
                                SizedBox(
                                  height: 5,
                                ), // Add spacing between icon and text
                                Text(
                                  "Track location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedOpacity(
                                opacity: _showtracking ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 200),
                                child: Container(
                                  height: 1.0,
                                  color: Colors
                                      .orange, // Color of the horizontal line
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.fade,
                                              alignment: Alignment.bottomCenter,
                                              duration:
                                                  Duration(milliseconds: 400),
                                              child: LiveTracking()));
                                    });
                                  },
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 1.0,
                      ),
                      // Container(
                      //   height: 30.0, // height of the line
                      //   width: 1.0, // width of the line
                      //   color: Colors.orange, // color of the line
                      // ),
                      // SizedBox(
                      //   width: 8.0,
                      // ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(
                              0.5), // Background color with opacity
                          borderRadius: BorderRadius.circular(
                              8.0), // Optional: Border radius for rounded corners
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_online,
                                  color: Colors.black,
                                  size: 22.0,
                                ),
                                SizedBox(
                                  height: 5,
                                ), // Add spacing between icon and text
                                Text(
                                  "Location history",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedOpacity(
                                opacity: _showhistory ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 200),
                                child: Container(
                                  height: 1.0,
                                  color: Colors
                                      .orange, // Color of the horizontal line
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            alignment: Alignment.bottomCenter,
                                            duration:
                                                Duration(milliseconds: 400),
                                            child: LocationHistory()));
                                  },
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 1.0,
                      ),
                      // Container(
                      //   height: 30.0, // height of the line
                      //   width: 1.0, // width of the line
                      //   color: Colors.orange, // color of the line
                      // ),
                      // SizedBox(
                      //   width: 8.0,
                      // ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(
                              0.5), // Background color with opacity
                          borderRadius: BorderRadius.circular(8.0),
                          // Optional: Border radius for rounded corners
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.speed,
                                  color: Colors.black,
                                  size: 22.0,
                                ),
                                SizedBox(
                                  height: 5,
                                ), // Add spacing between icon and text
                                Text(
                                  "Track speed",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedOpacity(
                                opacity: _showspeed ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 200),
                                child: Container(
                                  height: 1.0,
                                  color: Colors
                                      .orange, // Color of the horizontal line
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            alignment: Alignment.bottomCenter,
                                            duration:
                                                Duration(milliseconds: 400),
                                            child: MyHomePage()));
                                  },
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_showtracking)
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 116, 116, 116)
                                    .withOpacity(0.5), // Shadow color
                                spreadRadius: 5, // Spread radius
                                blurRadius: 7, // Blur radius
                                offset: Offset(0, 0), // Offset
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showtracking = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  if (_showhistory)
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 116, 116, 116)
                                    .withOpacity(0.5), // Shadow color
                                spreadRadius: 5, // Spread radius
                                blurRadius: 7, // Blur radius
                                offset: Offset(0, 0), // Offset
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Display',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  if (_showspeed)
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 116, 116, 116)
                                    .withOpacity(0.5), // Shadow color
                                spreadRadius: 5, // Spread radius
                                blurRadius: 7, // Blur radius
                                offset: Offset(0, 0), // Offset
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Speed',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showspeed = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    width: double.infinity,
                    height: 250.0, // Adjust the height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(2, 2),
                        )
                      ],
                      // color: Color.fromARGB(255, 23, 23, 23),
                      color: Colors.grey.shade700,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notifications",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(height: 10.0),
                        Expanded(
                            child: Scrollbar(
                          thickness: 5.0,
                          interactive: true,

                          ///thumbVisibility: true,
                          radius: Radius.circular(10.0),

                          child: ListView(
                            children: [
                              // Add your Notification widgets here
                              ListTile(
                                title: Text(
                                  "data",
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text("data information",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Divider(
                                color: Colors.grey[800],
                                thickness: 2.0,
                                indent: 15.0,
                                endIndent: 15.0,
                              ),
                              ListTile(
                                title: Text("data",
                                    style: TextStyle(color: Colors.white)),
                                subtitle: Text("data information",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Divider(
                                color: Colors.grey[800],
                                thickness: 2.0,
                                indent: 15.0,
                                endIndent: 15.0,
                              ),
                              ListTile(
                                title: Text("data",
                                    style: TextStyle(color: Colors.white)),
                                subtitle: Text("data information",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Divider(
                                color: Colors.grey[800],
                                thickness: 2.0,
                                indent: 15.0,
                                endIndent: 15.0,
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class PowerButton extends StatefulWidget {
  @override
  _PowerButtonState createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton> {
  bool isOn = false;
  bool isLocationSelected = false;
  //String _message = '';
  final telephony = Telephony.instance;

  onMessage(SmsMessage message) async {
    if (message.body.toString() == 'ON' &&
        message.address.toString() == '+923233465564') {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid);
      await userRef.update({'Engine_status': 'ON'});
    }
    if (message.body.toString() == 'OFF' &&
        message.address.toString() == '+923233465564') {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid);
      await userRef.update({'Engine_status': 'OFF'});
    }
  }

  void listenForEngineStatus() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Engine_status')
        .onValue
        .listen((event) {
      if (event.snapshot.value.toString() == 'ON') {
        setState(() {
          isOn = true;
        });
      }
      if (event.snapshot.value.toString() == 'OFF') {
        setState(() {
          isOn = false;
        });
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }

  void permission() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted == true) {
      print('granted');
      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          listenInBackground: true,
          onBackgroundMessage: onBackgroundMessage);
    }
  }

  @override
  void initState() {
    super.initState();
    permission();
    listenForEngineStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              title: Text('Confirmation'),
              content: Text('Are you sure? '),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // setState(() {
                    //   isOn = !isOn;
                    // });
                    if (!isOn) {
                      telephony.sendSms(to: '03233465564', message: 'ON');
                    } else {
                      telephony.sendSms(to: '03233465564', message: 'OFF');
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.orange : Colors.transparent,
              boxShadow: isOn
                  ? [
                      BoxShadow(
                        color: Colors.orange,
                        offset: Offset(0, 0),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ]
                  : [],
              border: Border.all(
                color: isOn ? Colors.transparent : Colors.orange,
                width: 3,
              ),
            ),
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.power_settings_new,
                  size: 40,
                  color: isOn ? Colors.white : Colors.orange,
                ),
                SizedBox(height: 10),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 20,
                    color: isOn ? Colors.white : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLocationSelected = !isLocationSelected;
                      });
                    },
                    child: Text(
                      'Engine Status',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 9.0,
                  ),
                  Text(
                    isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 20,
                      color: isOn ? Colors.grey.shade700 : Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
