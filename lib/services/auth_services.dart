import 'package:asaf/animations/processing.dart';
import 'package:asaf/screens/from.dart';
import 'package:asaf/screens/homepage.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

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

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('DriveSenseUsers')
                .doc(user.uid)
                .collection('userData')
                .doc(user.uid)
                .get();

            if (!userDoc.exists) {
              DateTime signUpDate = DateTime.now();
              int signUpYear = signUpDate.year;
              await _firestore
                  .collection('DriveSenseUsers')
                  .doc(user.uid)
                  .collection('userData')
                  .doc(user.uid)
                  .set({
                'fullname': user.displayName,
                'email': user.email,
                'signupdate': signUpDate.toLocal(),
                'signupyear': signUpYear,
                'userid': user.uid,
                'profilestatus': 'pending',
                'formfilled': 'false',
                'gprofileImageUrl': 'non',
              });
            }
          } catch (e) {
            // Handle the error
            print('Error fetching user document: $e');
          }

          final userDocc = await FirebaseFirestore.instance
              .collection('DriveSenseUsers')
              .doc(user.uid)
              .collection('userData')
              .doc(user.uid)
              .get();
          final profileVerificationStatus = userDocc['profilestatus'] ?? '';
          final formfilled = userDocc['formfilled'] ?? '';
          Navigator.of(context).pop();
          Utils().errortoast('Signed in as ${user.displayName}', context);
          if (formfilled == 'false' && profileVerificationStatus == 'pending') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const InfoForm(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var slideAnimation = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves
                          .easeOutCubic, // You can adjust the curve for desired easing
                    ),
                  );

                  return SlideTransition(
                    position: slideAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                    milliseconds:
                        800), // Adjust the duration for a slower animation
              ),
            );
          } else if (profileVerificationStatus == 'pending' &&
              formfilled == 'true') {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Processing(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var slideAnimation = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves
                          .easeOutCubic, // You can adjust the curve for desired easing
                    ),
                  );

                  return SlideTransition(
                    position: slideAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                    milliseconds:
                        800), // Adjust the duration for a slower animation
              ),
            );
            // Exit the function here
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var slideAnimation = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves
                          .easeOutCubic, // You can adjust the curve for desired easing
                    ),
                  );

                  return SlideTransition(
                    position: slideAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                    milliseconds:
                        800), // Adjust the duration for a slower animation
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }
}
