import 'package:flutter/material.dart';

class SerialDialog extends StatelessWidget {
  final List<dynamic> serial;

  const SerialDialog({
    Key? key,
    required this.serial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      height: height * 0.5,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: width,
            height: height * 0.05,
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Serial Number',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 2),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: serial.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: ListTile(
                      leading: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.1,
                        ),
                      ),
                      title: Text('${serial[index]}'),
                    ),
                  );
                }),
          ),
          // Expanded(
          //     child: Container(
          //   alignment: Alignment.center,
          //   // color: Colors.blue,
          //   child: Text(
          //     serial,
          //     style: TextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // )),
        ],
      ),
    );
  }

  static Future showSerialDialog(BuildContext context, List<dynamic> serialNo) {
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
          content: SerialDialog(
            serial: serialNo,
          ),
        );
      },
    );
  }
}
