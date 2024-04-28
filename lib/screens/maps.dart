import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:asaf/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart' as loc;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GlobalKey _positionedKey = GlobalKey();
  //late MapBoxOptions _navigationOption;
  var oldLatitude = 0.0;
  var oldLongitude = 0.0;
  Animation<double>? animation;
  bool isrequestednewlocation = false;
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _newlocationController = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '12345';
  static final CameraPosition _kGoogleplex = CameraPosition(
    target: LatLng(24.802336801597523, 67.0300194951321),
    zoom: 14,
  );
  List<Location> locations = [];
  bool navigationstarted = false;
  GlobalKey _containerKey = GlobalKey();
  List<Marker> _marker = [];
  List<dynamic> _placeslist = [];
  String distance = '';
  bool isserviceRequested = false;
  double distanceInMeters = 0;
  double _fabBottomPadding = 0.0;
  String kPlacesApi = 'AIzaSyDIQQ7PPMh1M3lDmw2yB_9Mm71qLno-rQc';

  List<LatLng> latlang = [];
  String maneuverr = "";
  String distancetext = "";
  String durationtext = "";
  List<LatLng> polylineCoordinates = [];
  List<dynamic> points = [];
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<Map<String, dynamic>> directionSteps = [];
  late StreamSubscription<Position> positionStream;
  AnimationController? animationController;

  addDriverMarker(LatLng oldPos, LatLng newDriverPos) async {
    final Uint8List markerIcon =
        await getBytesFromAsset(Constants.driverCarImage, 100);
    MarkerId id = const MarkerId("driverMarker");

    AnimationController animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: false);

    Tween<double> tween = Tween(begin: 0, end: 1);

    animation = tween.animate(animationController)
      ..addListener(() {
        final v = animation!.value;

        double lng = v * newDriverPos.longitude + (1 - v) * oldPos.longitude;

        double lat = v * newDriverPos.latitude + (1 - v) * oldPos.latitude;

        LatLng newPos = LatLng(lat, lng);
        Marker newCar = Marker(
            markerId: id,
            position: newPos,
            visible: true,
            rotation: 0,
            icon: BitmapDescriptor.fromBytes(markerIcon));

        _marker.add(newCar);
        //update();
      });
    animationController.forward();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> getDirections(Position origin, Position destination) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/directions/json';
    String request =
        '$baseURL?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$kPlacesApi';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      Map<String, dynamic> directions = jsonDecode(response.body);
      parseDirections(directions); // Call parseDirections here
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  void drawdirection() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true);
    getDirections(
      Position(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: 0.0, // Provide the required accuracy parameter
        altitude: 0.0, // Provide the required altitude parameter
        altitudeAccuracy:
            0.0, // Provide the required altitudeAccuracy parameter
        heading: 0.0, // Provide the required heading parameter
        timestamp: DateTime.now(), // Provide the required timestamp parameter
        headingAccuracy: 0.0, // Provide the required headingAccuracy parameter
        speed: 0.0, // Provide the required speed parameter
        speedAccuracy: 0.0, // Provide the required speedAccuracy parameter
      ),
      Position(
        latitude: locations.last.latitude,
        longitude: locations.last.longitude,
        accuracy: 0.0, // Provide the required accuracy parameter
        altitude: 0.0, // Provide the required altitude parameter
        altitudeAccuracy:
            0.0, // Provide the required altitudeAccuracy parameter
        heading: 0.0, // Provide the required heading parameter
        timestamp: DateTime.now(), // Provide the required timestamp parameter
        headingAccuracy: 0.0, // Provide the required headingAccuracy parameter
        speed: 0.0, // Provide the required speed parameter
        speedAccuracy: 0.0, // Provide the required speedAccuracy parameter
      ),
    );
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kPlacesApi,
        PointLatLng(position.latitude, position.longitude),
        PointLatLng(locations.last.latitude, locations.last.longitude),
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lang': point.longitude});
      });
    } else {
      print(result.errorMessage);
    }
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 7);

    polylines[id] = polyline;

    setState(() {});
    double minLatitude = min(position.latitude, locations.last.latitude);
    double maxLatitude = max(position.latitude, locations.last.latitude);
    double minLongitude = min(position.longitude, locations.last.longitude);
    double maxLongitude = max(position.longitude, locations.last.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: bounds.southwest,
            northeast: bounds.northeast,
          ),
          100),
    );
  }

  Future moveMapCamera(LatLng target,
      {double zoom = 20, double bearing = 0}) async {
    CameraPosition newCameraPosition =
        CameraPosition(target: target, zoom: zoom, bearing: bearing);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  List<Map<String, dynamic>> parseDirections(Map<String, dynamic> directions) {
    List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];

    for (var step in steps) {
      String instruction =
          step['html_instructions'].replaceAll(RegExp(r'<[^>]*>'), '');

      // Extract maneuver (e.g., turn-left, turn-right)
      String maneuver = step['maneuver'] ?? '';

      // Extract distance and duration
      String distanceText = step['distance']['text'];
      int distanceValue = step['distance']['value'];

      String durationText = step['duration']['text'];
      int durationValue = step['duration']['value'];

      // Extract polyline points if needed
      String polyline = step['polyline']['points'];

      // Add the parsed step data to the list
      directionSteps.add({
        'instruction': instruction,
        'maneuver': maneuver,
        'distanceText': distanceText,
        'distanceValue': distanceValue,
        'durationText': durationText,
        'durationValue': durationValue,
        'polyline': polyline,
      });
    }

    return directionSteps;
  }

  void checklocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      bool serviceRequested = await location.requestService();
      if (serviceRequested) {
        setState(() {
          isserviceRequested = true;
        });
      } else {
        setState(() {
          isserviceRequested = false;
        });
        return;
      }
    } else {
      setState(() {
        isserviceRequested = true;
      });
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    checklocation();
    _searchController.addListener(onChange);
  }

  void onChange() {
    if (_sessionToken == '') {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    String input = _searchController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _placeslist.clear();
      });
    } else {
      getSuggestion(input);
    }
  }

  Future<void> getSuggestion(String input) async {
    // Replace with your Google Places API Key
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPlacesApi&components=country:PK';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeslist = jsonDecode(response.body)['predictions'];
      });
    } else {
      setState(() {
        _placeslist = [];
      });
      throw Exception('Failed to load suggestions');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(
      String placeId, String apiKey) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      Map<String, dynamic> placeDetails = jsonDecode(response.body);
      return placeDetails;
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                polylines: Set<Polyline>.of(polylines.values),
                markers: Set<Marker>.of(_marker),
                initialCameraPosition: _kGoogleplex,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
              if (!navigationstarted)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 9,
                    shadowColor: Colors.black,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Expanded(
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
                              hintText: 'Destination',
                              prefixIcon: const Icon(Icons.pin_drop),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_placeslist.isNotEmpty)
                Positioned(
                  top: 80.2,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 5,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _placeslist.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            locations = await locationFromAddress(
                                _placeslist[index]['description']);
                            GoogleMapController controller =
                                await _controller.future;
                            controller.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                  LatLng(locations.last.latitude,
                                      locations.last.longitude),
                                  14),
                            );
                            setState(() {
                              _marker.clear();

                              _marker.add(Marker(
                                infoWindow: InfoWindow(
                                  title: _placeslist[index]['description'],
                                ),
                                markerId: const MarkerId('selected-location'),
                                position: LatLng(locations.last.latitude,
                                    locations.last.longitude),
                              ));

                              _placeslist.clear();
                              _searchController.clear();
                            });
                            if (isserviceRequested) {
                              Position position =
                                  await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.high,
                                      forceAndroidLocationManager: true);

                              double distanceInMeter =
                                  await Geolocator.distanceBetween(
                                      position.latitude,
                                      position.longitude,
                                      locations.last.latitude,
                                      locations.last.longitude);
                              getDirections(
                                Position(
                                  latitude: position.latitude,
                                  longitude: position.longitude,
                                  accuracy:
                                      0.0, // Provide the required accuracy parameter
                                  altitude:
                                      0.0, // Provide the required altitude parameter
                                  altitudeAccuracy:
                                      0.0, // Provide the required altitudeAccuracy parameter
                                  heading:
                                      0.0, // Provide the required heading parameter
                                  timestamp: DateTime
                                      .now(), // Provide the required timestamp parameter
                                  headingAccuracy:
                                      0.0, // Provide the required headingAccuracy parameter
                                  speed:
                                      0.0, // Provide the required speed parameter
                                  speedAccuracy:
                                      0.0, // Provide the required speedAccuracy parameter
                                ),
                                Position(
                                  latitude: locations.last.latitude,
                                  longitude: locations.last.longitude,
                                  accuracy:
                                      0.0, // Provide the required accuracy parameter
                                  altitude:
                                      0.0, // Provide the required altitude parameter
                                  altitudeAccuracy:
                                      0.0, // Provide the required altitudeAccuracy parameter
                                  heading:
                                      0.0, // Provide the required heading parameter
                                  timestamp: DateTime
                                      .now(), // Provide the required timestamp parameter
                                  headingAccuracy:
                                      0.0, // Provide the required headingAccuracy parameter
                                  speed:
                                      0.0, // Provide the required speed parameter
                                  speedAccuracy:
                                      0.0, // Provide the required speedAccuracy parameter
                                ),
                              );

                              setState(() {
                                distanceInMeters = distanceInMeter / 1000;
                                String formattedDistance =
                                    distanceInMeters.toStringAsFixed(1) + ' km';
                                distance = formattedDistance;
                              });
                            }
                            RenderBox box = _positionedKey.currentContext!
                                .findRenderObject() as RenderBox;
                            double _heeight = box.size.height;
                            setState(() {
                              _fabBottomPadding = _heeight;
                            });
                          },
                          title: Text(_placeslist[index]['description']),
                        );
                      },
                    ),
                  ),
                ),
              if (_marker.isNotEmpty)
                Positioned(
                  key: _positionedKey,
                  bottom: 50,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 9,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  key: _containerKey,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _marker.first.infoWindow.title ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                "$distance",
                                style: TextStyle(
                                    fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${locations.last.latitude}, ${locations.last.longitude}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          if (navigationstarted)
                            GestureDetector(
                              onTap: () {
                                points.clear();
                                _marker.clear();
                                polylines.clear();
                                directionSteps.clear();
                                locations.clear();
                                polylineCoordinates.clear();

                                setState(() {
                                  navigationstarted = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Text("Exit",
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ),
                          if (!navigationstarted)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (isserviceRequested) {
                                      drawdirection();
                                    }
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.directions,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Material(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.blue,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8.0),
                                    onTap: () {
                                      setState(() {
                                        isrequestednewlocation = true;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        'Change Starting Point?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                if (isserviceRequested)
                                  GestureDetector(
                                    onTap: () async {
                                      Position position =
                                          await Geolocator.getCurrentPosition(
                                              desiredAccuracy:
                                                  LocationAccuracy.high,
                                              forceAndroidLocationManager:
                                                  true);
                                      final _origin = WayPoint(
                                          name: "Way Point 1",
                                          latitude: position.latitude,
                                          longitude: position.longitude,
                                          isSilent: true);
                                      final _destination = WayPoint(
                                          name: "Way Point 1",
                                          latitude: locations.last.latitude,
                                          longitude: locations.last.longitude,
                                          isSilent: true);
                                      var wayPoints = <WayPoint>[];
                                      wayPoints.add(_origin);
                                      wayPoints.add(_destination);

                                      await MapBoxNavigation.instance
                                          .startNavigation(
                                        wayPoints: wayPoints,
                                      );
                                      // if (polylines.isEmpty) {
                                      //   drawdirection();
                                      // }
                                      // positionStream =
                                      //     Geolocator.getPositionStream(
                                      //         locationSettings:
                                      //             LocationSettings(
                                      //   accuracy: LocationAccuracy.high,
                                      //   distanceFilter: 1,
                                      // )).listen((Position? position) async {
                                      //   LatLng newPosition = LatLng(
                                      //       position!.latitude,
                                      //       position.longitude);
                                      //   addDriverMarker(
                                      //       LatLng(oldLatitude, oldLongitude),
                                      //       newPosition);
                                      //   oldLatitude = position.latitude;
                                      //   oldLongitude = position.longitude;
                                      //   moveMapCamera(newPosition,
                                      //       zoom: 17,
                                      //       bearing: position.heading);
                                      // });
                                      // setState(() {
                                      //   navigationstarted = true;
                                      // });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                      ),
                                      child: Image.asset(
                                        'assets/images/car.png', // Replace 'your_image.png' with your asset image path
                                        width: 40,
                                        height: 40,
                                        // Optional: apply color to the image
                                      ),
                                    ),
                                  )
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (navigationstarted)
                Positioned(
                  // Adjust as per your requirement
                  left: 16, // Adjust as per your requirement
                  right: 16,
                  top: 16, // Adjust as per your requirement
                  child: Material(
                    elevation: 9,
                    shadowColor: Colors.black,
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (directionSteps[0]['manovier'] == 'turn-right')
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.west,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          SizedBox(
                              width:
                                  8), // Add some spacing between icon and text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  directionSteps[0]['instruction'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  directionSteps[0]['distanceText'],
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                // Add more direction instructions as needed
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (isrequestednewlocation)
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 9,
                    shadowColor: Colors.black,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newlocationController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Sarting Location',
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          //if (_marker.isNotEmpty)
        ),
        floatingActionButton: !navigationstarted
            ? Padding(
                padding: EdgeInsets.only(
                    bottom: _marker.isNotEmpty ? _fabBottomPadding + 50 : 30),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: isserviceRequested
                      ? Icon(
                          Icons.location_searching_sharp,
                          size: 30,
                          color: Colors.black,
                        )
                      : Icon(
                          Icons.location_disabled,
                          size: 30,
                        ),
                  onPressed: () async {
                    loc.Location location = loc.Location();
                    bool serviceEnabled = await location.serviceEnabled();
                    if (!serviceEnabled) {
                      bool serviceRequested = await location.requestService();
                      if (serviceRequested) {
                        Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                            forceAndroidLocationManager: true);
                        GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target:
                                  LatLng(position.latitude, position.longitude),
                              zoom: 14,
                            ),
                          ),
                        );
                        setState(() {
                          isserviceRequested = true;
                        });
                      } else {
                        setState(() {
                          isserviceRequested = false;
                        });
                        return;
                      }
                    } else {
                      setState(() {
                        isserviceRequested = true;
                      });
                    }

                    LocationPermission permission =
                        await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      return;
                    }

                    Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                        forceAndroidLocationManager: true);
                    GoogleMapController controller = await _controller.future;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 15,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
              )
            : null);
  }
}
