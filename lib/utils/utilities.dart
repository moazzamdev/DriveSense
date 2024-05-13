import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class Utils {
  void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  void errortoast(String message, context) {
    ToastService.showToast(
      context,
      isClosable: false,
      backgroundColor: Color(0xff3a3b3c),
      shadowColor: Color.fromARGB(193, 36, 37, 38),
      length: ToastLength.short,
      expandedHeight: 0,
      message: message,
      messageStyle: TextStyle(fontSize: 15, color: Colors.white),
      leading: Image.asset(
        'assets/images/icon.png',
        height: 25,
        width: 25,
      ),

      // leading: const Icon(
      //   Icons.error,
      //   size: 20,
      //   color: Colors.white,
      // ),
      slideCurve: Curves.elasticInOut,
      positionCurve: Curves.bounceOut,
      dismissDirection: DismissDirection.none,
    );
  }
}
