import 'package:asaf/screens/chatscreen.dart';
import 'package:asaf/screens/dashborad.dart';
import 'package:asaf/screens/mapbox.dart';
import 'package:asaf/screens/maps.dart';
import 'package:asaf/settings/settings.dart';
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
  @override
  void initState() {
    super.initState();
    fetchUserName();
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
      Dashboard(),
      SettingsScreen(
        urlimage: imageurl,
      ),
      ChatScreen(),
      MapScreen(),
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
          icon: Icon(Icons.chat),
          title: "Chat",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.pin_drop),
          title: "Navigation",
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
