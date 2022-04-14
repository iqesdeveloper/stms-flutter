// Extended Raised button for Open Flutter E-commerce App
// Author: openflutterproject@gmail.com
// Date: 2020-02-06

import 'package:flutter/material.dart';
// import 'package:jomngo/config/theme.dart';

class StmsStyleButton extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback onPressed;
  final String title;
  final FontWeight titleWeight;
  final IconData? icon;
  final double iconSize;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  StmsStyleButton({
    Key? key,
    this.width,
    this.height,
    required this.title,
    this.titleWeight = FontWeight.normal,
    required this.onPressed,
    this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.borderColor = Colors.white,
    this.iconSize = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);
    var heightButton = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height != null ? height : heightButton / 15,
        // padding: edgeInsets,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildIcon(_theme),
              _buildTitle(_theme),
            ],
          ),
        ),
      ),
      // ),
    );
    /*RaisedButton(
      onPressed: onPressed,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(
          AppSizes.buttonRadius
        )
      ),
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        child: Text(title,
          style: _theme.textTheme.button.copyWith(
            backgroundColor: _theme.textTheme.button.backgroundColor,
            color: _theme.textTheme.button.color
          )
        )
      )
    );*/
  }

  Widget _buildTitle(ThemeData _theme) {
    return Text(
      title,
      style: _theme.textTheme.button?.copyWith(
        backgroundColor: _theme.textTheme.button?.backgroundColor,
        color: textColor,
        fontSize: 18, //16
        fontWeight: titleWeight,
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: textColor, //theme.textTheme.button?.color,
        ),
      );
    }

    return SizedBox();
  }
}
