import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';

class LocationHistory extends StatefulWidget {
  const LocationHistory({super.key});

  @override
  State<LocationHistory> createState() => _LocationHistoryState();
}

class _LocationHistoryState extends State<LocationHistory> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogleplex = CameraPosition(
    target: LatLng(24.802336801597523, 67.0300194951321),
    zoom: 14,
  );
  List<Marker> _marker = [];
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
              left: 100, // Adjust as per your requirement
              right: 100,
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
                        'Location History',
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
    );
  }
}
