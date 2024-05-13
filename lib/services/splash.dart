import 'dart:async';
import 'package:asaf/animations/onboarding.dart';
import 'package:asaf/animations/processing.dart';
import 'package:asaf/auth_screens/email_verfication.dart';
import 'package:asaf/screens/from.dart';
import 'package:asaf/screens/homepage.dart';
import 'package:asaf/services/startscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final auth = FirebaseAuth.instance;
final user = auth.currentUser;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () async {
      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('DriveSenseUsers')
              .doc(user!.uid)
              .collection('userData')
              .doc(user!.uid)
              .get();
          final profileVerificationStatus = userDoc['profilestatus'] ?? '';
          final formfilled = userDoc['formfilled'] ?? '';
          if (!user!.emailVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerfication(),
              ),
            );
          } else if (formfilled == 'false' &&
              profileVerificationStatus == 'pending') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InfoForm(),
              ),
            );
          } else if (profileVerificationStatus == 'pending' &&
              formfilled == 'true') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Processing(),
              ),
            );
            // Exit the function here
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          }
        } catch (e) {
          print('Error logging in: $e');
        } finally {
          // Close the dialog
        }
      } else if (user == null) {
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
          if (isFirstTime == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OnBoarding(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StartScreen()),
            );
          }
        } catch (e) {
          print('Error');
        }
      } else {
        // User is null, navigate to the start screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StartScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150.0,
              height: 150.0,
            ),
            SizedBox(height: 20.0),
            LoadingAnimationWidget.halfTriangleDot(
              color: const Color.fromRGBO(255, 152, 0, 1),
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
