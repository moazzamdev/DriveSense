import 'package:asaf/auth_screens/login.dart';
import 'package:asaf/screens/from.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmailVerfication extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff3a3b3c),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset(
                  'assets/images/email_animation.json',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 60.0),
                Text(
                  'Verify Your Email Address',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white),
                ),
                SizedBox(height: 30.0),
                Text(
                  'We have just sent an email verification to your email address. Please check your email and click on the link to verify your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 30.0),
                Text(
                  'If not auto redirected after verification, click on the Continue button.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: OutlinedButton(
                      onPressed: () async {
                        User? user = _auth.currentUser;
                        user!.reload();

                        user = _auth.currentUser;

                        if (user != null && user.emailVerified) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => InfoForm()),
                          );
                        } else {
                          Utils().toastMessage(
                              'Please Verify Your Email or Press Continue Again!');
                        }
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser!
                        .sendEmailVerification();
                  },
                  child: Text(
                    'Resend Email Verification Link',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.0), // Add spacing between icon and text
                      Text(
                        'Back to Login',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
