// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// class SpeedWidget extends StatefulWidget {
//   @override
//   _SpeedWidgetState createState() => _SpeedWidgetState();
// }

// class _SpeedWidgetState extends State<SpeedWidget> {
//   var speed;

//   @override
//   void initState() {
//     super.initState();
//     listenForSpeedUpdates();
//   }

//   void listenForSpeedUpdates() {
//     DatabaseReference reference = FirebaseDatabase.instance.ref();

//     reference
//         .child('users')
//         .child(FirebaseAuth.instance.currentUser!.uid)
//         .child('speed')
//         .onValue
//         .listen((event) {
//       if (event.snapshot.value != null) {
//         setState(() {
//           speed = event.snapshot.value;
//           if (speed != 0) {
//             var kph = speed * 3.6;
//             var rounded = kph.round();
//             speed = rounded;
//           }
//         });
//       }
//     }, onError: (error) {
//       print('Error listening for speed updates: $error');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
//       width: double.infinity,
//       height: 70.0,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             spreadRadius: 3,
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           )
//         ],
//         color: Colors.white,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "Realtime Speed",
//             style: TextStyle(fontSize: 20),
//           ),
//           Text(
//             speed != null ? '${speed} KM/h' : '0 KM/h',
//             style: TextStyle(fontSize: 20),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  return runApp(GaugeApp());
}

/// Represents the GaugeApp class
class GaugeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radial Gauge Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

/// Represents MyHomePage class
class MyHomePage extends StatefulWidget {
  /// Creates the instance of MyHomePage
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var speed;
  double speedd = 0.0;
  String selectedSpeedLimit = '100';
  int limitt = 0;
  int speeed = 0;
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
            speedd = kph;
            var rounded = kph.round();
            speed = rounded;
            speeed = speed;
            print(speeed);
            if (speed > limitt) {
              AwesomeNotifications().createNotification(
                  content: NotificationContent(
                      backgroundColor: Colors.white,
                      id: 6444,
                      channelKey: 'drivesense',
                      title: 'Speed Limit',
                      body: 'Your Speed Limit is exceeding',
                      category: NotificationCategory.Call,
                      wakeUpScreen: true,
                      duration: Durations.extralong1),
                  actionButtons: [
                    NotificationActionButton(
                        key: 'ACTION_OK',
                        label: 'Dismiss',
                        actionType: ActionType
                            .DisabledAction // Payload to identify the action
                        ),
                  ]);
            }
          }
        });
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }

  void listenForSpeedlimit() {
    DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference
        .child('users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('speed_limit')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          var limit = event.snapshot.value;
          if (limit != null) {
            selectedSpeedLimit = limit.toString();
            if (selectedSpeedLimit == '100') {
              setState(() {
                limitt = 100;
                print(limitt);
              });
            }
            if (selectedSpeedLimit == '120') {
              setState(() {
                limitt = 120;
              });
            }
            if (selectedSpeedLimit == '150') {
              setState(() {
                limitt = 150;
              });
            }
            if (selectedSpeedLimit == '50') {
              setState(() {
                limitt = 50;
                print(limitt);
              });
            }
            if (selectedSpeedLimit == '80') {
              setState(() {
                limitt = 80;
              });
            }
          }
        });
      }
    }, onError: (error) {
      print('Error listening for speed updates: $error');
    });
  }


  @override
  void initState() {
    super.initState();
    listenForSpeedlimit();
    listenForSpeedUpdates();
  }

  Widget _getGauge({bool isRadialGauge = true}) {
    if (isRadialGauge) {
      return _getRadialGauge();
    } else {
      return _getLinearGauge();
    }
  }

  Widget _getRadialGauge() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(minimum: 0, maximum: 150, ranges: <GaugeRange>[
        GaugeRange(
            startValue: 0,
            endValue: 50,
            color: Colors.green,
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 50,
            endValue: 100,
            color: Colors.orange,
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 100,
            endValue: 150,
            color: Colors.red,
            startWidth: 10,
            endWidth: 10)
      ], pointers: <GaugePointer>[
        NeedlePointer(value: speed != 0 ? speedd : 0)
      ], annotations: <GaugeAnnotation>[
        GaugeAnnotation(
            widget: Container(
                child: Text(speed != 0 ? '${speed} KM/h' : '0 KM/h',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
            angle: 90,
            positionFactor: 0.5)
      ])
    ]);
  }

  Widget _getLinearGauge() {
    return Container(
      child: SfLinearGauge(
          minimum: 0.0,
          maximum: 100.0,
          orientation: LinearGaugeOrientation.horizontal,
          majorTickStyle: LinearTickStyle(length: 20),
          axisLabelStyle: TextStyle(fontSize: 12.0, color: Colors.black),
          axisTrackStyle: LinearAxisTrackStyle(
              color: Colors.cyan,
              edgeStyle: LinearEdgeStyle.bothFlat,
              thickness: 15.0,
              borderColor: Colors.grey)),
      margin: EdgeInsets.all(10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
          child: Stack(children: [
        _getGauge(),
        Positioned(
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
          left: 85,
          right: 85,
          top: 16,
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
                    'Live Speed Tracking',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Speed Limit',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  //SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedSpeedLimit,
                    onChanged: (String? newValue) async {
                      setState(() {
                        selectedSpeedLimit = newValue!;
                      });

                      // Update speed limit in the database
                      DatabaseReference speedLimitRef = FirebaseDatabase
                          .instance
                          .ref()
                          .child('users')
                          .child(FirebaseAuth.instance.currentUser!.uid)
                          .child('speed_limit');
                      await speedLimitRef.set(selectedSpeedLimit);
                    },
                    items: <String>['50', '80', '100', '120', '150']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('$value km/h'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ])),
    );
  }
}
