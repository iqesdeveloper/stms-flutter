// Extended Raised button for Open Flutter E-commerce App
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:flutter/material.dart';
// import 'package:jomngo/config/theme.dart';

class StmsIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback onPressed;
  final String title;
  final FontWeight titleWeight;
  final IconData? icon;
  final double iconSize;
  final Color? backgroundColor;
  final Color textColor;
  final Color borderColor;

  StmsIconButton({
    Key? key,
    this.width,
    this.height,
    required this.title,
    this.titleWeight = FontWeight.normal,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderColor = Colors.white,
    this.iconSize = 45.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var _theme = Theme.of(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // return InkWell(
    //   child: Container(
    //     color: Colors.amber,
    //     height: height * 0.18,
    //     width: width * 0.31,
    //     child: MaterialButton(
    //       onPressed: onPressed,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Container(
    //             width: 50.0,
    //             height: 50.0,
    //             child: Icon(
    //               icon,
    //               size: iconSize,
    //             ),
    //           ),
    //           // SizedBox(height: height * 0.01),
    //           Container(
    //             width: 130.0,
    //             height: height * 0.5,
    //             // alignment: Alignment.center,
    //             child: Text(
    //               title,
    //               textAlign: TextAlign.center,
    //               style: TextStyle(
    //                 fontSize: 16,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    return Material(
      // color: Colors.amber,
      child: Container(
        width: width * 0.35,
        height: height * 0.2,
        color: Colors.white,
        child: MaterialButton(
          onPressed: onPressed,
          child: Column(
            children: [
              Container(
                width: 90.0,
                height: 65.0,
                child: Icon(
                  icon,
                  size: iconSize,
                ),
              ),
              Container(
                width: 200, //width * 0.8,
                height: 80.0,
                // alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
