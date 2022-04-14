// Extended Raised button for Open Flutter E-commerce App
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:flutter/material.dart';
// import 'package:jomngo/config/theme.dart';

class StmsImageButton extends StatelessWidget {
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
  final String assetImage;

  StmsImageButton({
    Key? key,
    this.width,
    this.height,
    required this.title,
    this.titleWeight = FontWeight.normal,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderColor = Colors.white,
    this.iconSize = 18.0,
    required this.assetImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var _theme = Theme.of(context);
    // var heightButton = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: MaterialButton(
        onPressed: onPressed,
        child: Column(
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 130.0,
              height: 40.0,
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
    );
  }
}
