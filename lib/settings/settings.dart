import 'dart:io';
import 'package:asaf/auth_screens/change_password.dart';
import 'package:asaf/screens/chatscreen.dart';
import 'package:asaf/settings/privacypolicy.dart';
import 'package:asaf/settings/support.dart';
import 'package:asaf/settings/termsandconditions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asaf/services/startscreen.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String urlimage;
  SettingsScreen({super.key, required this.urlimage});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String name = '';
  String imageurl = '';

  void initState() {
    super.initState();
    fetchUserName();
  }

  String success = '';
  File? _image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void _showImagePreviewDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Preview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(imageFile),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: SpinKitDoubleBounce(
                          color: Colors.orange,
                          size: 50.0,
                        ),
                      );
                    },
                  );
                  Future.delayed(const Duration(seconds: 3), () {
                    // Dismiss the dialog after the delay
                    Navigator.pop(context);
                  });

                  _uploadImageAndSaveLink(imageFile);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Show the image preview dialog
      _showImagePreviewDialog(_image!);
    } else {
      Utils().errortoast('No image slelected', context);
    }
  }

  Future<void> _uploadImageAndSaveLink(File imageFile) async {
    final user = _auth.currentUser;
    final userId = user?.uid;

    // Fetch current image URL from Firestore
    final userDoc = await _firestore
        .collection('DriveSenseUsers')
        .doc(userId)
        .collection('userData')
        .doc(userId)
        .get();
    final currentImageUrl = userDoc['gprofileImageUrl'];

    if (currentImageUrl != 'non') {
      if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(currentImageUrl);
        await storageRef.delete();
      }
    }
    final storageRef =
        _storage.ref().child('images/$userId/${DateTime.now().toString()}');
    await storageRef.putFile(imageFile);

    // Get the download URL of the uploaded image
    final imageUrl = await storageRef.getDownloadURL();

    // Update the user's database entry with the new image URL
    await _firestore
        .collection('DriveSenseUsers')
        .doc(userId)
        .collection('userData')
        .doc(userId)
        .update({
      'gprofileImageUrl': imageUrl,
    });
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
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the reference to the user document
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('DriveSenseUsers')
            .doc(user.uid)
            .collection('userData')
            .doc(user.uid);

        // Create a snapshot listener for real-time updates
        userRef.snapshots().listen((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            String userName = snapshot.get('fullname');
            String imageurll = snapshot.get('gprofileImageUrl');

            setState(() {
              name = userName;
              imageurl = imageurll;

              // Cache the fetched name
              prefs.setString('userName', userName);
              prefs.setString('gprofileImageUrl', imageurll);
            });
          } else {
            print('User document does not exist');
          }
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
      // Handle the error here, such as displaying an error message to the user.
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 23, 23, 23),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 23, 23, 23),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: buildAvatar(
                        widget.urlimage,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        _pickAndUploadImage();
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.black,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$name", style: TextStyle(color: Colors.white))
                  ],
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "General",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile settings',
                        style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.arrow_forward_ios_sharp),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password',
                        style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.arrow_forward_ios_sharp),
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              alignment: Alignment.bottomCenter,
                              duration: Duration(milliseconds: 400),
                              child: ChangePassword()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Data",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('Information',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {},
                    trailing: Icon(Icons.arrow_forward_ios_sharp),
                  ),
                  ListTile(
                    title: Text('Change data',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {},
                    trailing: Icon(Icons.arrow_forward_ios_sharp),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Terms and Support",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title:
                        Text('Support', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Support()));
                    },
                  ),
                  ListTile(
                    title: Text('Terms and conditions',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermsandConditions()));
                    },
                  ),
                  ListTile(
                    title: Text('Privacy policys',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicy()));
                    },
                  ),
                  Divider(
                    color: Colors.grey[800],
                    thickness: 2.0,
                    indent: 15.0,
                    endIndent: 15.0,
                  ),
                  ListTile(
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    leading: Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
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
                      bool loggedOut = await signOut();
                      if (loggedOut) {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const StartScreen();
                            },
                          ),
                          (_) => false,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future signOut() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.currentUser;
    onUserLogout();
    await FirebaseMessaging.instance.unsubscribeFromTopic(user!.uid);
    return true;
  } catch (e) {
    print('Error during sign out: $e');
    return false;
  }
}

Widget buildAvatar(String imageurl) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('DriveSenseUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Return a placeholder widget while waiting for data
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Handle any errors
        return Text('Error: ${snapshot.error}');
      } else {
        // Retrieve the image URL from the snapshot data
        final imageUrl = snapshot.data!['gprofileImageUrl'];

        if (imageUrl == 'non') {
          return Image.asset(
            'assets/images/usericon.jpg',
            fit: BoxFit.cover,
          );
        } else {
          return CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          );
        }
      }
    },
  );
}
