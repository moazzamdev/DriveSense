import 'package:asaf/screens/chatscreen.dart';
import 'package:asaf/screens/mainscreen.dart';
import 'package:asaf/screens/maps.dart';
import 'package:asaf/screens/remote.dart';
import 'package:asaf/settings/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  String imageurl = '';
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchRequestsCount();
  }

  void fetchRequestsCount() async {
    // Get a reference to the Firestore collection
    final collectionReference = FirebaseFirestore.instance
        .collection('DriveSenseUsers')
        .doc(userid)
        .collection('requests');

    // Listen to changes in the collection
    collectionReference.snapshots().listen((snapshot) {
      // Update the count of requests
      setState(() {
        _requestCount = snapshot.docs.length;
      });
    });
  }

  Future<void> fetchUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final cachedUserName = prefs.getString('userName') ?? '';

      final cachedimageurl = prefs.getString('gprofileImageUrl') ?? '';
      if (cachedUserName.isNotEmpty) {
        setState(() {
          name = cachedUserName;

          imageurl = cachedimageurl;
        });
        return;
      }
    } catch (e) {
      print("Error fetching user name: $e");
      // Handle the error here, such as displaying an error message to the user.
    }
  }

  final _controller = PersistentTabController(initialIndex: 0);

  List<Widget> screens() {
    return [
      DashboardScreen(),
      SettingsScreen(
        urlimage: imageurl,
      ),
      ChatScreen(),
      MapScreen(),
      Remote()
    ];
  }

  List<PersistentBottomNavBarItem> navBarItems() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: "Home",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.settings),
          title: "Settings",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Stack(
            children: [
              Icon(Icons.chat),
              if (_requestCount > 0)
                Positioned(
                  right: 0,
                  left: 15,
                  bottom: 15,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    // child: Text(
                    //   '$_requestCount',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 10,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                  ),
                ),
            ],
          ),
          title: "Chat",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.pin_drop),
          title: "Navigation",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.settings_remote),
          title: "Remote",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 80),
      child: PersistentTabView(
        context,
        screens: screens(),
        items: navBarItems(),
        controller: _controller,
        navBarStyle: NavBarStyle.style1,
        popAllScreensOnTapAnyTabs: true,
        backgroundColor: Color(0xff242526),
        decoration: NavBarDecoration(
            colorBehindNavBar: Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            adjustScreenBottomPaddingOnCurve: true),
        margin: EdgeInsets.all(0.0),
      ),
    );
  }
}
