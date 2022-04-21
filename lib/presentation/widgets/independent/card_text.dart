import 'package:flutter/material.dart';
// import 'package:jomngo/config/theme.dart';

class StmsCard extends StatelessWidget {
  final double? heightBox;
  final String title1;
  final String title2;
  final String? title3;
  final String? title4;
  final String subtitle1;
  final String subtitle2;
  final String? subtitle3;
  final String? subtitle4;

  const StmsCard({
    Key? key,
    this.heightBox,
    required this.title1,
    required this.title2,
    this.title3,
    this.title4,
    required this.subtitle1,
    required this.subtitle2,
    this.subtitle3,
    this.subtitle4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      // height: heightBox == null ? height * 0.16 : heightBox,
      padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
      decoration: new BoxDecoration(
        // color: Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.3,
                child: Text(
                  title1,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
              Text(
                ": ",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle1,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: width * 0.3,
                child: Text(
                  title2,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.left,
                ),
              ),
              Text(
                ": ",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle2,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          subtitle3 != null
              ? Row(
                  children: [
                    Container(
                      width: width * 0.3,
                      child: Text(
                        title3!,
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      ": ",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      subtitle3!,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Container(),
          subtitle4 != null
              ? Row(
                  children: [
                    Container(
                      width: width * 0.3,
                      child: Text(
                        title4!,
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      ": ",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.6,
                      child: Text(
                        subtitle4!,
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    )

                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
