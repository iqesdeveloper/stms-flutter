import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String mainText;

  const SuccessDialog({Key? key, required this.mainText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightGreenAccent[700],
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: MediaQuery.of(context).size.height * 0.07,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                mainText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  // primary: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // JomNGoStyleButton(
              //   backgroundColor: AppColors.deepSkyBlue,
              //   // height: MediaQuery.of(context).size.height * 0.05,
              //   width: MediaQuery.of(context).size.width * 0.3,
              //   title: 'OK',
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
            ),
          ),
        ],
      ),
    );
  }

  static Future showSuccessDialog(BuildContext context, String text) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: SuccessDialog(
            mainText: text,
          ),
        );
      },
    );
  }
}
