import 'package:flutter/material.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
// import 'package:jomngo/config/theme.dart';

class StmsMenuLine extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const StmsMenuLine({
    Key? key,
    required this.title,
    this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // InkWell(
        //   child:
        Container(
          height: MediaQuery.of(context).size.height / 12,
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                // fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              subtitle!,
              style: TextStyle(
                color: Colors.grey.shade300,
                // fontWeight: FontWeight.bold,
              ),
            ),
            trailing: StmsStyleButton(
              title: 'Download',
              height: height * 0.05,
              width: width * 0.3,
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: onTap,
            ),
            //Icon(Icons.chevron_right),
          ),
        ),
        // onTap: onTap,
        // ),
        SizedBox(
          height: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 0.5, color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }
}
