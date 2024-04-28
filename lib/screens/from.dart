import 'package:asaf/animations/doneAnimation.dart';
import 'package:asaf/services/startscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:asaf/utils/utilities.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

User? user = FirebaseAuth.instance.currentUser;

class InfoForm extends StatefulWidget {
  const InfoForm({super.key});

  @override
  State<InfoForm> createState() => _InfoFormState();
}

class _InfoFormState extends State<InfoForm> {
  TextEditingController mobile_no = TextEditingController();
  TextEditingController _dob = TextEditingController();
  TextEditingController cnic_no = TextEditingController();
  TextEditingController vehicle_type = TextEditingController();
  TextEditingController vehicle_name = TextEditingController();
  TextEditingController vehicle_model = TextEditingController();
  TextEditingController vehcile_reg_no = TextEditingController();
  TextEditingController vehicle_owner = TextEditingController();
  TextEditingController _address = TextEditingController();
  final _infoformKey = GlobalKey<FormState>();
  String? _selectedVehicleType;

  @override
  void dispose() {
    mobile_no.dispose();
    _dob.dispose();
    cnic_no.dispose();
    vehicle_type.dispose();
    vehicle_name.dispose();
    vehicle_model.dispose();
    vehcile_reg_no.dispose();
    vehicle_owner.dispose();
    _address.dispose();
    super.dispose();
  }

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    _dob = TextEditingController(text: ""); // Initialize with an empty string
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Color(0xff3a3b3c),
            appBar: AppBar(
              backgroundColor: Color(0xff3a3b3c),
              title: const Text(
                'User Information',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return SpinKitDoubleBounce(
                            color: Colors.orange, // Customize color if needed
                            size: 50.0, // Customize size if needed
                          );
                        },
                      );

                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const StartScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var slideAnimation = Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves
                                    .easeOutCubic, // You can adjust the curve for desired easing
                              ),
                            );

                            return SlideTransition(
                              position: slideAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(
                              milliseconds:
                                  800), // Adjust the duration for a slower animation
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 8, right: 15, top: 2, bottom: 2),
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff3a3b3c),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 70.0),
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Form(
                        key: _infoformKey,
                        child: Column(
                          children: [
                            TextFormField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                controller: cnic_no,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  hintText: 'CNIC Number',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your CNIC number';
                                  }

                                  return null;
                                },
                                onEditingComplete: () {
                                  if (cnic_no.text.isEmpty) {
                                    Utils().toastMessage('Empty Field!');
                                  } else {
                                    // Move focus to the password field when "Tab" is pressed
                                    FocusScope.of(context).nextFocus();
                                  }
                                }),
                            SizedBox(height: 20.0),

                            //DOB-------------------------------------------------
                            Row(
                              children: [
                                // Date of Birth TextField
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.white),
                                    controller: _dob,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      hintText: 'YYYY-MM-DD',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.orange),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );

                                      if (pickedDate != null) {
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                        setState(() {
                                          _dob.text = formattedDate;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        7), // Add some space between the two input fields
                                // CNIC TextFormField
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: Colors.white),
                                    controller: mobile_no,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      hintText: 'Mobile No',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(
                                        Icons.phone,
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.orange),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Mobile number';
                                      }
                                      return null;
                                    },
                                    onEditingComplete: () {
                                      if (mobile_no.text.isEmpty) {
                                        Utils().toastMessage('Empty Field!');
                                      } else {
                                        // Move focus to the next field when "Tab" is pressed
                                        FocusScope.of(context).nextFocus();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedVehicleType,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedVehicleType = newValue;
                                        vehicle_type.text = newValue ?? '';
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a vehicle type';
                                      }
                                      return null;
                                    },

                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'Car',
                                        child: Text('Car',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Jeep',
                                        child: Text('Jeep',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'EV Car',
                                        child: Text('EV Car',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'EV Jeep',
                                        child: Text('EV Jeep',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                    style: TextStyle(
                                        color: Colors
                                            .white), // Set text color to white
                                    dropdownColor: Colors
                                        .black, // Set dropdown background color to orange
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      hintText: 'Vehicle Type',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(
                                        Icons.car_repair,
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.orange),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 7.0,
                                ),
                                Expanded(
                                  child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      controller: vehicle_model,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        hintText: 'Vehicle Model',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.numbers,
                                          color: Colors.grey,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.orange,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your Vehicle model';
                                        }

                                        return null;
                                      },
                                      onEditingComplete: () {
                                        if (vehicle_model.text.isEmpty) {
                                          Utils().toastMessage('Empty Field!');
                                        } else {
                                          // Move focus to the password field when "Tab" is pressed
                                          FocusScope.of(context).nextFocus();
                                        }
                                      }),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                                keyboardType: TextInputType.text,
                                style: const TextStyle(color: Colors.white),
                                controller: vehicle_name,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  hintText: 'Vehicle Name',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(
                                    Icons.branding_watermark,
                                    color: Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Vehicle name';
                                  }

                                  return null;
                                },
                                onEditingComplete: () {
                                  if (vehicle_name.text.isEmpty) {
                                    Utils().toastMessage('Empty Field!');
                                  } else {
                                    // Move focus to the password field when "Tab" is pressed
                                    FocusScope.of(context).nextFocus();
                                  }
                                }),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                                keyboardType: TextInputType.text,
                                style: const TextStyle(color: Colors.white),
                                controller: vehcile_reg_no,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  hintText:
                                      'Vehicle Registration No Eg. ABC123',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(
                                    Icons.numbers,
                                    color: Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your vehicle registration number/numberplate';
                                  }

                                  return null;
                                },
                                onEditingComplete: () {
                                  if (vehcile_reg_no.text.isEmpty) {
                                    Utils().toastMessage('Empty Field!');
                                  } else {
                                    // Move focus to the password field when "Tab" is pressed
                                    FocusScope.of(context).nextFocus();
                                  }
                                }),
                            SizedBox(
                              height: 20.0,
                            ),

                            TextFormField(
                                keyboardType: TextInputType.name,
                                style: const TextStyle(color: Colors.white),
                                controller: vehicle_owner,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  hintText: 'Vehicle Owner Name',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: Colors.grey,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Vehicles owner name';
                                  }

                                  return null;
                                },
                                onEditingComplete: () {
                                  if (vehicle_owner.text.isEmpty) {
                                    Utils().toastMessage('Empty Field!');
                                  } else {
                                    // Move focus to the password field when "Tab" is pressed
                                    FocusScope.of(context).nextFocus();
                                  }
                                }),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.streetAddress,
                              style: const TextStyle(color: Colors.white),
                              controller: _address,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                hintText: 'Address',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(
                                  Icons.map,
                                  color: Colors.grey,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.orange,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Address';
                                }

                                return null;
                              },
                              onEditingComplete: () {
                                if (_address.text.isEmpty) {
                                  Utils().toastMessage('Empty Field!');
                                } else {
                                  // Move focus to the password field when "Tab" is pressed
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 1000.0,
                              height: 40.0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_infoformKey.currentState!.validate()) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return SpinKitDoubleBounce(
                                          color: Colors
                                              .orange, // Customize color if needed
                                          size:
                                              50.0, // Customize size if needed
                                        );
                                      },
                                    );
                                    await FirebaseFirestore.instance
                                        .collection('DriveSenseUsers')
                                        .doc(user!.uid)
                                        .collection('userData')
                                        .doc(user!.uid)
                                        .update({
                                      'cnic': cnic_no.text.toString(),
                                      'dob': _dob.text.toString(),
                                      'phone': mobile_no.text.toString(),
                                      'vehiclename':
                                          vehicle_name.text.toString(),
                                      'vehiclenumber': vehcile_reg_no.text
                                          .toUpperCase()
                                          .toString(),
                                      'vehicleowner':
                                          vehicle_owner.text.toString(),
                                      'address': _address.text.toString(),
                                      'carmodel': vehicle_model.text.toString(),
                                      'vehicletype':
                                          _selectedVehicleType.toString(),
                                      'profilestatus': 'pending',
                                      'formfilled': 'true'
                                    });

                                    await FirebaseFirestore.instance
                                        .collection('DriveSenseUsers')
                                        .doc(user!.uid)
                                        .set({
                                      'vehiclenumber': vehcile_reg_no.text
                                          .toUpperCase()
                                          .toString(),
                                    });
                                    Navigator.of(context).pop();

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DonePage(),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 60,
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            )));
  }
}
