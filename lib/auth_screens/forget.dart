import 'package:asaf/auth_screens/login.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                              hintText: 'Registered Email',
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
                        SizedBox(height: 10.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                              );
                            },
                            child: const Text(
                              'Remember Password?',
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
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: SpinKitDoubleBounce(
                                        color: Colors
                                            .orange, // Choose your desired color
                                        size: 50.0, // Choose your desired size
                                      ),
                                    );
                                  },
                                );

                                try {
                                  await _auth
                                      .sendPasswordResetEmail(
                                          email:
                                              _emailController.text.toString())
                                      .then((value) {});

                                  // Close the loading indicator
                                  Navigator.pop(context);

                                  Utils().errortoast(
                                      'Password reset link sent. Check your email.',
                                      context);

                                  // Navigate to the next screen after successful login
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          Login(),
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
                                } on FirebaseAuthException catch (e) {
                                  // Close the loading indicator
                                  Navigator.of(context).pop();

                                  String errorMessage = '';
                                  if (e.code == 'user-not-found') {
                                    errorMessage = 'Invalid email';
                                  } else if (e.code ==
                                      'reset-password-email-sent') {
                                    errorMessage =
                                        'Password reset link sent. Check your email.';
                                  } else {
                                    errorMessage =
                                        'An error occurred. Please try again.';
                                    print('Error: ${e.message}');
                                  }

                                  // Display the error message using a Snackbar
                                  Utils().errortoast(errorMessage, context);
                                } catch (e) {
                                  // Close the loading indicator
                                  Navigator.of(context).pop();

                                  // Handle other errors
                                  print('Error: $e');
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
                              "Reset Password",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
