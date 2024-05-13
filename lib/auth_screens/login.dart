import 'package:asaf/animations/processing.dart';
import 'package:asaf/auth_screens/forget.dart';
import 'package:asaf/auth_screens/register.dart';
import 'package:asaf/screens/from.dart';
import 'package:asaf/screens/homepage.dart';
import 'package:asaf/services/auth_services.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/images/loginback.jpeg'), context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginback.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 170.0),
                    height: 150.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/logo.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 70.0),
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            controller: _emailController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              hintText: 'Email',
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onEditingComplete: () {
                              if (_emailController.text.isEmpty) {
                                Utils().toastMessage('Empty Field!');
                              } else {
                                // Move focus to the password field when "Tab" is pressed
                                FocusScope.of(context).nextFocus();
                              }
                            }),
                        SizedBox(height: 20.0),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: _passwordController,
                          obscureText:
                              !_passwordVisible, // Toggle password visibility
                          maxLines: 1,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            // Additional password validation logic can be added here
                            return null;
                          },
                          onEditingComplete: () {
                            if (_passwordController.text.isEmpty) {
                              Utils().toastMessage('Empty Field!');
                            } else {
                              // Handle submission or move to the next field as needed
                            }
                          },
                        ),
                        SizedBox(
                          height: 0.0,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ForgetScreen()),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 1000.0,
                          height: 40.0,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return SpinKitDoubleBounce(
                                      color: Colors
                                          .orange, // Customize color if needed
                                      size: 50.0, // Customize size if needed
                                    );
                                  },
                                );
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );

                                  final userDoc = await FirebaseFirestore
                                      .instance
                                      .collection('DriveSenseUsers')
                                      .doc(user!.uid)
                                      .collection('userData')
                                      .doc(user!.uid)
                                      .get();
                                  final profileVerificationStatus =
                                      userDoc['profilestatus'] ?? '';
                                  final formfilled =
                                      userDoc['formfilled'] ?? '';
                                  Navigator.of(context).pop();
                                  if (formfilled == 'false' &&
                                      profileVerificationStatus == 'pending') {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const InfoForm(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
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
                                  } else if (profileVerificationStatus ==
                                          'pending' &&
                                      formfilled == 'true') {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            Processing(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
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
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const HomePage(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
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
                                } on FirebaseAuthException catch (e) {
                                  // Close the loading indicator
                                  Navigator.of(context).pop();

                                  String errorMessage = '';
                                  if (e.code == 'user-not-found' ||
                                      e.code == 'wrong-password') {
                                    errorMessage = 'Invalid email or password.';
                                  } else {
                                    errorMessage =
                                        'An error occurred. Please try again.';
                                    print('Error: ${e.message}');
                                  }

                                  // Display the error message using a Snackbar
                                  Utils().errortoast(errorMessage, context);
                                } catch (e) {
                                  print('Error logging in: $e');
                                } finally {
                                  // Close the dialog
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "or continue with",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 500,
                          height: 40, // Set the desired width here
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                10), // Set the desired border radius here
                          ),
                          child: SignInButton(
                            Buttons.google,
                            onPressed: () =>
                                AuthService().signInWithGoogle(context),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        Register(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
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
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
