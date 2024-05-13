import 'package:asaf/services/startscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class Processing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return SpinKitDoubleBounce(
                        color: Colors.orange, // Customize color if needed
                        size: 50.0, // Customize size if needed
                      );
                    },
                  );

                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StartScreen()));
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 8, right: 15, top: 2, bottom: 2),
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset(
                  'assets/images/processing_animation.json',
                  width: 400,
                  height: 400,
                ),
                Text(
                  'Request Processing',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                SizedBox(height: 30.0),
                Text(
                  'Please wait while we process your request, our team will get back to you then. Thanks for you patience',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
