import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset(
                  'assets/images/done_animation.json',
                  width: 400,
                  height: 400,
                ),
                Text(
                  'User Data Saved Successfully',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                SizedBox(height: 30.0),
                Text(
                  'Your data has been saved. We will get back to you soon!',
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
