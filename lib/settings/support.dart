import 'package:flutter/material.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 23, 23, 23),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Add functionality to navigate back when the button is pressed
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Support",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 23, 23, 23),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "if you have any query mail us at:\n70110519@student.uol.edu.pk\nor\n70111156@student.uol.edu.pk",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            )
          ],
        ));
  }
}
