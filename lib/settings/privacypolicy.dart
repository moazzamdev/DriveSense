import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 23, 23, 23),
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
          "Privacy Policy",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18.0),
          child: Column(
            children: [
              Text(
                "Information Collection: The System may collect personal and non-personal information from users, including but not limited to name, email address, vehicle information, and location data. This information is used to provide and improve the System's functionality.\nData Usage: Collected data may be used for various purposes, including but not limited to vehicle tracking, driver behavior analysis, and communication between users. Data may also be shared with third-party service providers for the purpose of system operation and maintenance.\nData Security: The project team takes reasonable measures to protect the security and integrity of collected data. However, no data transmission over the internet or storage system can be guaranteed to be 100% secure. Users are advised to take precautions to protect their personal information.\nInformation Sharing: Collected data may be shared with law enforcement agencies, emergency services, or other authorized entities in accordance with applicable laws and regulations.\nOpt-Out: Users may opt out of certain data collection and usage by disabling location services or other features of the System. However, this may limit the functionality of the System.\nPolicy Changes: This privacy policy may be updated or revised from time to time. Users will be notified of any changes to the policy by email or through the System's interface.\nContact Information: If you have any questions or concerns about this privacy policy or the System's data practices, please contact us at 70110519@student.uol.edu.pk\nor\n70111156@student.uol.edu.pk.",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
