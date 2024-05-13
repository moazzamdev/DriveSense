import 'package:asaf/screens/homepage.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:youtube_data_api/youtube_data_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  String video_id = '';
  late YoutubePlayerController _controller;

  TextEditingController _searchController = TextEditingController();
  YoutubeDataApi youtubeDataApi = YoutubeDataApi();
  var author_imageurl;
  bool isPlaying = false;
  String fileName = '';
  bool isMute = true;
  bool isAudioPlaying = false;
  var listener_imageurl;
  var listener_vehicle_number;
  bool isConditionMet = true;
  bool isSwitched = true;
  String invitor_id = '';
  bool showListener = false;
  bool isAudioMute = true;
  var secondid;
  List<Map<String, String>> suggestions = [];
  var count;
  var author_vehicle_number;
  var createdid;
  User? user;
  bool author = false;
  bool issuggestion = false;
  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });
  }

  void ifAuthor() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('author')
        .onValue
        .listen((event) {
      if (event.snapshot.exists && event.snapshot.value.toString() == 'false') {
        setState(() {
          author = true;
          isConditionMet = false;
        });
      }
    });
  }

  void listenForVideoId() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('music_room')
        .child(invitor_id)
        .child('video_id')
        .onValue
        .listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        setState(() {
          video_id = event.snapshot.value.toString();
          _controller = YoutubePlayerController(
            initialVideoId: video_id,
            flags: YoutubePlayerFlags(
                autoPlay: false, mute: false, hideControls: true),
          );
          _controller.load(video_id);
        });
      }
    });
  }

  void listenForAuthor() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Author')
        .child('vehicle_number')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          author_vehicle_number = event.snapshot.value.toString();
        });
      }
    });
    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Author')
        .child('imageurl')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          author_imageurl = event.snapshot.value.toString();
        });
      }
    });
  }

  void listenForListener() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Listener')
        .child('vehicle_number')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          listener_vehicle_number = event.snapshot.value.toString();
        });
      }
    });
    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Listener')
        .child('imageurl')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          listener_imageurl = event.snapshot.value.toString();
        });
      }
    });
  }

  void listenForCount() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();
    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('total_users')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          count = event.snapshot.value;
          print(count);
        });
      }
    });
  }

  void getUserid() {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('DriveSenseUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    userRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String idd = snapshot.get('room_invitor') ?? '';
        setState(() {
          invitor_id = idd;
          print(invitor_id);
        });
      }
    });
  }

  void joinedListener() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('music_room')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Listener')
        .child('joined')
        .onValue
        .listen((event) {
      if (event.snapshot.value.toString() == 'true') {
        Utils().errortoast('Invited User Joined Room', context);
        setState(() {
          showListener = true;
        });
      } else if (event.snapshot.value.toString() == 'false') {
        setState(() {
          showListener = false;
        });
      }
    });
  }

  Future<void> getSuggestion(String input) async {
    suggestions.clear();
    List result = await youtubeDataApi.fetchSearchVideo(
        input, 'AIzaSyCqcHnlKWpdoKNkhJjxHxCL3_kCCWNMrlw');

    for (int i = 0; i < result.length; i++) {
      var video = result[i];
      suggestions.add({
        'index': '$i',
        'title': video.title,
        'videoId': video.videoId,
      });
    }
    setState(() {
      issuggestion = true;
    });
    for (int i = 0; i < 6; i++) {
      var suggestion = suggestions[i];
      print('Index: ${suggestion['index']}');
      print('Title: ${suggestion['title']}');
      print('Video ID: ${suggestion['videoId']}');
      print('---');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserid();
    listenForVideoId();
    listenForAuthor();
    listenForCount();
    listenForListener();
    ifAuthor();
    joinedListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Music Streaming',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                DatabaseReference reference = FirebaseDatabase.instance.ref();

                reference.child('music_room').remove();
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        alignment: Alignment.bottomCenter,
                        duration: Duration(milliseconds: 400),
                        child: HomePage()));
              },
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.red,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Exit",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              child: Column(
                children: [
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                      ),
                      Icon(
                        Icons.people,
                        size: 30,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '$count',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 120,
                      ),
                      //if (author)
                      Switch(
                        value: isConditionMet ? true : false,
                        onChanged: _toggleSwitch,
                        activeTrackColor: Colors.orange.shade100,
                        activeColor: Colors.orange,
                      ),
                      SizedBox(
                        width: 05,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 17,
                        backgroundImage: NetworkImage('$author_imageurl'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 2, right: 30),
                            child: Text(
                              'Author',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          Text(
                            '$author_vehicle_number',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Material(
                  elevation: 5,
                  shadowColor: Colors.black,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: TextFormField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search On YouTube',
                      prefixIcon: const Icon(Icons.music_note),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          getSuggestion(_searchController.text.toString());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 220,
              right: 20,
              left: 20,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 5,
                        blurRadius: 4,
                        offset: Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        20), // Rounded corners for the video player
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.amber,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.amber,
                        handleColor: Colors.amberAccent,
                      ),
                      onReady: () {
                        _controller.pause();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 450,
              left: 100,
              right: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPlaying = !isPlaying;
                        if (isPlaying) {
                          _controller.play();
                        } else {
                          _controller.pause();
                        }
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMute = !isMute;
                        if (isMute) {
                          _controller.unMute();
                        } else {
                          _controller.mute();
                        }
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: Icon(
                        isMute ? Icons.volume_up : Icons.volume_off,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (issuggestion)
              Positioned(
                top: 170,
                left: 20,
                right: 20,
                child: Material(
                  elevation: 5,
                  shadowColor: Colors.black,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          DatabaseReference reference =
                              FirebaseDatabase.instance.ref();

                          reference
                              .child('music_room')
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            'video_id': suggestions[index]['videoId'].toString()
                          });
                          setState(() {
                            issuggestion = false;
                          });
                        },
                        title: Text(suggestions[index]['title'].toString()),
                      );
                    },
                  ),
                ),
              ),
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100, // Background color
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  20.0), // Rounded corners on the right side
                              bottomRight: Radius.circular(20.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // Shadow color
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 2), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black,
                                backgroundImage:
                                    NetworkImage('$listener_imageurl'),
                                radius: 17,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 2, right: 25),
                                    child: Text(
                                      'Listener',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  Text(
                                    '$listener_vehicle_number',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
