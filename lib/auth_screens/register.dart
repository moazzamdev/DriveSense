import 'package:asaf/auth_screens/email_verfication.dart';
import 'package:asaf/auth_screens/login.dart';
import 'package:asaf/services/auth_services.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _usernamecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernamecontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/images/registerback.jpeg'), context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/registerback.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 170.0),
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/logo2.png',
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
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(color: Colors.white),
                          controller: _usernamecontroller,
                          maxLines: 1,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'Full Name',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.person,
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
                              return 'Please enter your Full Name';
                            }

                            return null;
                          },
                          onEditingComplete: () {
                            if (_emailcontroller.text.isEmpty) {
                              Utils().toastMessage('Empty Field!');
                            } else {
                              // Move focus to the password field when "Tab" is pressed
                              FocusScope.of(context).nextFocus();
                            }
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          controller: _emailcontroller,
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
                            if (_emailcontroller.text.isEmpty) {
                              Utils().toastMessage('Empty Field!');
                            } else {
                              // Move focus to the password field when "Tab" is pressed
                              FocusScope.of(context).nextFocus();
                            }
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _passwordcontroller,
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
                          if (_passwordcontroller.text.isEmpty) {
                            Utils().toastMessage('Empty Field!');
                          } else {
                            // Handle submission or move to the next field as needed
                          }
                        },
                      ),
                      SizedBox(
                        height: 0.0,
                      ),
                      SizedBox(
                        height: 20.0,
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
                                await _auth
                                    .createUserWithEmailAndPassword(
                                  email: _emailcontroller.text.toString(),
                                  password: _passwordcontroller.text.toString(),
                                )
                                    .then((userCredential) async {
                                  DateTime signUpDate = DateTime.now();
                                  int signUpYear = signUpDate.year;

                                  await FirebaseFirestore.instance
                                      .collection('DriveSenseUsers')
                                      .doc(userCredential.user!.uid)
                                      .collection('userData')
                                      .doc(userCredential.user!.uid)
                                      .set({
                                    'fullname':
                                        _usernamecontroller.text.toString(),
                                    'email': _emailcontroller.text.toString(),
                                    'signupdate': signUpDate.toLocal(),
                                    'signupyear': signUpYear,
                                    //'userid': user!.uid,
                                    'gprofileImageUrl': 'non',
                                    'formfilled': 'false',
                                    'profilestatus': 'pending',
                                    'room_invitor': 'null'
                                  });
                                  await userCredential.user!
                                      .sendEmailVerification();

                                  Navigator.of(context).pop();

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmailVerfication(),
                                    ),
                                  );
                                  Utils().errortoast(
                                      'Sign up successful!', context);
                                });
                              } on FirebaseAuthException catch (e) {
                                String errorMessage = '';
                                if (e.code == 'email-already-in-use') {
                                  errorMessage =
                                      'This email is already in use.';
                                } else if (e.code == 'weak-password') {
                                  errorMessage = 'Password is too weak.';
                                } else {
                                  errorMessage =
                                      'An error occurred. Please try again.';
                                  print('Error: ${e.message}');
                                }

                                Utils().errortoast(errorMessage, context);
                                //Navigator.of(context).pop();
                              } catch (e) {
                                //Navigator.of(context).pop();
                                print('Error: $e');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            "Register",
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
                            "Already have an account?",
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
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
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
