import 'package:flutter/material.dart';

class TermsandConditions extends StatelessWidget {
  const TermsandConditions({super.key});

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
          "Terms and Conditions",
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
                "Acceptance of Terms: By accessing or using the IoT and Machine Learning-based Vehicle Security and Management System, you agree to be bound by these terms and conditions. \nUse of the System: The System is provided for the purpose of enhancing vehicle security, monitoring, and safety. You agree to use the System solely for lawful purposes and in accordance with these terms and conditions. \nUser Accounts: In order to access certain features of the System, you may be required to create a user account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. \nData Collection: The System may collect and store various types of data, including but not limited to vehicle location, speed, and driver behavior. By using the System, you consent to the collection and use of this data for the purposes outlined in the privacy policy. \nIntellectual Property: All intellectual property rights related to the System, including but not limited to software, trademarks, and content, are owned by or licensed to the project team. You agree not to copy, modify, or distribute any part of the System without prior written consent. \nLimitation of Liability: The project team shall not be liable for any direct, indirect, incidental, special, or consequential damages arising out of or in any way connected with the use of the System, even if advised of the possibility of such damages. \nModification of Terms: The project team reserves the right to modify or update these terms and conditions at any time without prior notice. Continued use of the System after any such changes constitutes acceptance of the modified terms.",
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
