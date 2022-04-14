import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/local_db/outgoing/paivt/paivt_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class PaivtManual extends StatefulWidget {
  // final Function changeView;

  const PaivtManual({Key? key}) : super(key: key); //, required this.changeView

  @override
  _PaivtManualState createState() => _PaivtManualState();
}

class _PaivtManualState extends State<PaivtManual> {
  List paivtItemListing = [];
  List paivtSerialNo = [];
  List getInfoPaivt = [];
  var selectedLoc, selectedInvtry, tracking, infoPaivt;
  final TextEditingController itemSNController = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();

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

  Future<void> saveData(String serial) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    infoPaivt = prefs.getString('paivt_serialList');
    getInfoPaivt = json.decode(infoPaivt);

    // paivtSerialNo = getInfoPaivt['items'];
    var itemSerial =
        getInfoPaivt.firstWhereOrNull((element) => element == serial);
    print('serialNo: $itemSerial');

    if (itemSNKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial No. cannot be empty');
    } else if (null == itemSerial) {
      ErrorDialog.showErrorDialog(context, 'Serial No. not match');
    } else {
      DBPaivtItem().getAllPaivtItem().then((value) {
        if (value != null) {
          paivtItemListing = value;
          // print('item Serial list: $value');

          var itemPaivt = paivtItemListing.firstWhereOrNull(
              (element) => element['item_serial_no'] == serial);
          if (null == itemPaivt) {
            prefs.setString("itemBarcode", serial);

            Navigator.of(context).pushNamed(StmsRoutes.paivtItemDetail);
          } else {
            ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
          }
        } else {
          prefs.setString("itemBarcode", serial);

          // await Future.delayed(const Duration(seconds: 3));
          Navigator.of(context).pushNamed(StmsRoutes.paivtItemDetail);
        }
      });
    }
  }
}
