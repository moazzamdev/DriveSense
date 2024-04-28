import 'package:asaf/services/startscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  Future signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      FirebaseAuth.instance.currentUser;
      //await FirebaseMessaging.instance.unsubscribeFromTopic(user!.uid);
      return true;
    } catch (e) {
      print('Error during sign out: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            bool loggedOut = await signOut();
            if (loggedOut) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const StartScreen();
                  },
                ),
                (_) => false,
              );
            }
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
