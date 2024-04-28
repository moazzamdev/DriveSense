import 'package:asaf/screens/chatscreen.dart';
import 'package:asaf/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  NotificationServices notificationServices = NotificationServices();
  String greeting = '';
  String imageurll = '';
  String imageAsset = '';
  String name = '';
  String ownername = '';
  String vehcile_reg_no = '';
  String vehicletype = '';
  String vehicle_name = '';

  @override
  void initState() {
    super.initState();

    updateTime();
    fetchUserName();
    onUserLogin();
    //checkNotificationPersmission();

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.foregroundMessage();
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
        imageAsset = 'assets/images/sun.gif'; // Use your morning sun image
      });
    } else if (hour >= 12 && hour < 18) {
      // Afternoon
      setState(() {
        greeting = 'Good Afternoon';
        imageAsset = 'assets/images/sun.gif'; // Use your afternoon sun image
      });
    } else {
      // Evening/Night
      setState(() {
        greeting = 'Good Evening';
        imageAsset =
            'assets/images/moon.gif'; // Use your evening/night moon image
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/images/registerback.jpeg'), // Replace 'assets/background_image.jpg' with your actual image path
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 175, 175, 175).withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
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
                        "Hey! " + name,
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 10),
                      Text(
                        greeting,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
              ],
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            padding: EdgeInsets.all(16.0),
            // margin: EdgeInsets.fromLTRB(16.0, 200.0, 16.0, 0),
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                color: Colors.white70),

            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.shield,
                  color: Colors.black,
                  size: 40.0,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "  Engine Status",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "ON",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // color: Colors.white,
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            width: double.infinity,
            height: 70.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
                color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Realtime Speed",
                    style: TextStyle(
                      fontSize: 20,
                    )),
                Text(
                  "80 KM/h",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 15.0,
          ),

          //Notification container...................
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            width: double.infinity,
            height: 250.0, // Adjust the height as needed
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(2, 2),
                )
              ],
              color: Color.fromARGB(255, 23, 23, 23),
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
                        title:
                            Text("data", style: TextStyle(color: Colors.white)),
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
                        title:
                            Text("data", style: TextStyle(color: Colors.white)),
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

          //CarInfo Container...................

          SizedBox(
            height: 15.0,
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 30.0),
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
                color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Vehicle Information",
                    style: TextStyle(
                      fontSize: 20,
                    )),
                Divider(),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Owner name",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(ownername,
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Vehicle Type",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(vehicletype,
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Vehicle",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(vehicle_name,
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Registered Number",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(vehcile_reg_no,
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      )),
    ));
  }
}
