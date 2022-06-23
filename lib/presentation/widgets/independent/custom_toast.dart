import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

late FToast fToast;

void showCustomSuccess(String msg) {

  Widget toast = Container(
    margin: const EdgeInsets.only(bottom: 80),
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.black,
    ),
    child: Text(
      msg,
      style: TextStyle(
          color: Colors.white
      ),
    ),
  );

  fToast.showToast(
    child: toast,
    toastDuration: Duration(seconds: 2),
  );
}