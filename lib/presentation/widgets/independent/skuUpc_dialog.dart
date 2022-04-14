import 'package:flutter/material.dart';
import 'package:stms/config/storage.dart';

class SkuUpcDialog extends StatelessWidget {
  // final String mainText;

  const SkuUpcDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      height: height * 0.25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Container(
          //   alignment: Alignment.topRight,
          //   child: IconButton(
          //     padding: EdgeInsets.all(0),
          //     onPressed: () {
          //       // Storage().typeScan = 'cancel';
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(
          //       Icons.close,
          //       color: Colors.red,
          //     ),
          //   ),
          // ),
          Container(
            child: Text('Please choose type of scan.'),
          ),
          Container(
            height: height / 14,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                // primary: Colors.redAccent,
              ),
              onPressed: () {
                Storage().typeScan = 'sku';
                Navigator.pop(context);
              },
              child: Text(
                'Scan SKU',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            height: height / 14,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                // primary: Colors.redAccent,
              ),
              onPressed: () {
                Storage().typeScan = 'upc';
                Navigator.pop(context);
              },
              child: Text(
                'Scan UPC',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future showSkuUpcDialog(BuildContext context) {
    //, String text
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          // contentPadding: EdgeInsets.all(10.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: SkuUpcDialog(
              // mainText: text,
              ),
        );
      },
    );
  }
}
