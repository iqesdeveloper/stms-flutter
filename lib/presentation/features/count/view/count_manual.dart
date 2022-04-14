import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/local_db/count/count_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class CountManual extends StatefulWidget {
  // final Function changeView;

  const CountManual({Key? key}) : super(key: key); //, required this.changeView

  @override
  _CountManualState createState() => _CountManualState();
}

class _CountManualState extends State<CountManual> {
  List countItemListing = [];
  List countSerialNo = [];
  List getInfoCount = [];
  var selectedLoc, selectedInvtry, tracking, infoCount;
  final TextEditingController itemSNController = TextEditingController();
  // final TextEditingController itemQtyController = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();
  // final GlobalKey<StmsInputFieldState> itemQtyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileProcessing) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return StmsScaffold(
            title: '',
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    decoration: ShapeDecoration(
                      shape: ContinuousRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          style: BorderStyle.solid,
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: StmsInputField(
                      key: itemSNKey,
                      controller: itemSNController,
                      hint: 'Item Serial No',
                      validator: Validator.valueExists,
                      textline: TextDecoration.none,
                    ),
                  ),
                  // StmsInputField(
                  //   key: itemQtyKey,
                  //   controller: itemQtyController,
                  //   hint: 'Quantity',
                  //   keyboard: TextInputType.number,
                  //   validator: Validator.valueExists,
                  // ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: ButtonTheme(
                          minWidth: 200,
                          height: 50,
                          child: StmsStyleButton(
                            title: 'ENTER',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () {
                              // saveNewBarcode(itemSNController.text);
                              saveData(itemSNController.text);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // saveNewBarcode(String serial) {
  //   for (int i = 1; i < int.parse(itemQtyController.text); i++) {
  //     String res = String.format("001%03d", i);
  //   }
  // }

  Future<void> saveData(String serial) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    infoCount = prefs.getString('sc_serialList');
    getInfoCount = json.decode(infoCount);
    // print('manual serial: $getInfoPaiv');

    // paivSerialNo = getInfoPaiv['items'];
    var itemSerial =
        getInfoCount.firstWhereOrNull((element) => element == serial);
    // print('serialNo: $itemSerial');

    if (null == itemSerial) {
      ErrorDialog.showErrorDialog(context, 'Serial No. not match');
    } else {
      DBCountItem().getAllCountItem().then((value) {
        if (value != null) {
          countItemListing = value;
          // print('item Serial list: $value');

          var itemCount = countItemListing.firstWhereOrNull(
              (element) => element['item_serial_no'] == serial);
          if (null == itemCount) {
            prefs.setString("itemBarcode", serial);

            Navigator.of(context).pushNamed(StmsRoutes.countItemDetail);
          } else {
            ErrorDialog.showErrorDialog(context, 'Serial No. already exists.');
          }
        } else {
          prefs.setString("itemBarcode", serial);

          Navigator.of(context).pushNamed(StmsRoutes.countItemDetail);
        }
      });
    }
  }
}
