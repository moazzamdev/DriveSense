import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900], // Set the background color here
        body: Container(
          padding: EdgeInsets.only(top: 60.0 , left: 20.0 , right: 20.0,bottom: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("data", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
