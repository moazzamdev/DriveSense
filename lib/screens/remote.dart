import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Remote extends StatelessWidget {
  final DatabaseReference controlCommandRef =
      FirebaseDatabase.instance.ref().child("device/control_command");

  void sendCommand(String command) {
    controlCommandRef.set(command);
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("ESP32 Control"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => sendCommand("ON"),
                child: Text("Turn ON"),
              ),
              ElevatedButton(
                onPressed: () => sendCommand("OFF"),
                child: Text("Turn OFF"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}