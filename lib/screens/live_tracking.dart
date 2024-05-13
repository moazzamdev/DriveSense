import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';

class LiveTracking extends StatefulWidget {
  const LiveTracking({super.key});

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  var speed;
  var latitude;
  var longitude;

  void listenForSpeedUpdates() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('speed')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          speed = event.snapshot.value;
          if (speed != 0) {
            var kph = speed * 3.6;
            speed = kph;
            var rounded = kph.round();
            speed = rounded;
          }
        });
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }

  void listenForLocation() async {
    final DatabaseReference controlCommandRef =
        FirebaseDatabase.instance.ref().child("device/latitude");

    controlCommandRef.onValue.listen((event) {
      setState(() {
        double doubleValue = double.parse(event.snapshot.value.toString());
        latitude = doubleValue;
      });
    });
    final DatabaseReference controlCommandRe =
        FirebaseDatabase.instance.ref().child("device/longitude");
    controlCommandRe.onValue.listen((event) {
      setState(() {
        double doubleValue = double.parse(event.snapshot.value.toString());
        longitude = doubleValue;
        print("$latitude, $longitude");
        updateCamera();
      });
    });
  }

  void updateCamera() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
      ),
    );
    _marker.add(Marker(
      markerId: const MarkerId('selected-location'),
      position: LatLng(latitude, longitude),
    ));
  }

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogleplex = CameraPosition(
    target: LatLng(24.802336801597523, 67.0300194951321),
    zoom: 14,
  );
  List<Marker> _marker = [];
  @override
  void initState() {
    super.initState();
    listenForSpeedUpdates();
    listenForLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: Set<Marker>.of(_marker),
              initialCameraPosition: _kGoogleplex,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Positioned(
              // Adjust as per your requirement
              left: 10, // Adjust as per your requirement
              right: 330,
              top: 22, // Adjust as per your requirement
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Ionicons.arrow_back_circle,
                    size: 45,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              // Adjust as per your requirement
              left: 80, // Adjust as per your requirement
              right: 80,
              top: 16, // Adjust as per your requirement
              child: Material(
                elevation: 9,
                shadowColor: Colors.black,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Live Location Tracking',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 40, right: 310),
        child: FloatingActionButton(
          elevation: 9,
          backgroundColor: Colors.white,
          onPressed: () {},
          shape: CircleBorder(),
          child: Text(
            speed != 0 ? '$speed' : '0',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
