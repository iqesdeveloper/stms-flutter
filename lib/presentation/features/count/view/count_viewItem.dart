import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/count/count_model.dart';
import 'package:stms/data/api/models/count/count_non_model.dart';
import 'package:stms/data/api/repositories/api_json/api_common.dart';
import 'package:stms/data/api/repositories/api_json/api_count.dart';
import 'package:stms/data/local_db/count/count_non_scanItem.dart';
import 'package:stms/data/local_db/count/count_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class CountItemDetails extends StatefulWidget {
  // final Function changeView;

  const CountItemDetails({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _CountItemDetailsState createState() => _CountItemDetailsState();
}

class _CountItemDetailsState extends State<CountItemDetails> {
  var getCountItem = CountService();
  var getCommonData = CommonService();

  List inventoryList = [];
  List locList = [];
  List countItemList = [];
  List reasonList = [];
  var selectedLoc, selectedInvtry, selectedReason, tracking;
  final format = DateFormat("yyyy-MM-dd");
  final TextEditingController itemSNController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemQtyKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getCommon();
    getItemCount();
  }

  getItemCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // serialNo = prefs.getString('itemBarcode')!;

    selectedInvtry = prefs.getString('selectedIvID');
    itemSNController.text = prefs.getString('itemBarcode')!;
    tracking = prefs.getString('countTracking');
  }

  getCommon() {
    DBMasterInventory().getAllMasterInv().then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      } else {
        setState(() {
          inventoryList = value;
        });
      }
    });

    DBMasterLocation().getAllMasterLoc().then((value) {
      print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download location file at master page first');
      } else {
        setState(() {
          locList = value;
        });
      }
    });

    DBMasterReason().getAllMasterReason().then((value) {
      // print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download reason code file at master page first');
      } else {
        setState(() {
          reasonList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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
            body: SingleChildScrollView(
              child: Container(
                height: height * 0.9,
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Item Inventory ID',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              isDense: true,
                              iconSize: 28,
                              iconEnabledColor: Colors.amber,
                              items: inventoryList.map((item) {
                                return new DropdownMenuItem(
                                  child: Container(
                                      width: width * 0.8,
                                      child: Text(item['name'])),
                                  value: item['id'].toString(),
                                );
                              }).toList(),
                              isExpanded: false,
                              value:
                                  selectedInvtry, // == "" ? "" : selectedTxn,
                              onChanged: null,
                              // (String? newValue) {
                              //   setState(() {
                              //     selectedLoc = newValue!;
                              //     // print('transfer type: $transferType');
                              //   });
                              // },
                            ),
                          ),
                        );
                      },
                    ),
                    tracking == "2"
                        ? StmsInputField(
                            key: itemSNKey,
                            controller: itemSNController,
                            hint: 'Item Serial No',
                            validator: Validator.valueExists,
                          )
                        : StmsInputField(
                            key: itemQtyKey,
                            controller: itemQtyController,
                            hint: 'Quantity',
                            keyboard: TextInputType.number,
                            validator: Validator.valueExists,
                          ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Reason Code',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              isDense: true,
                              iconSize: 28,
                              iconEnabledColor: Colors.amber,
                              items: reasonList.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['code']),
                                  value: item['id'].toString(),
                                );
                              }).toList(),
                              isExpanded: false,
                              value:
                                  selectedReason, // == "" ? "" : selectedTxn,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedReason = newValue!;
                                  // print('transfer type: $transferType');
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Item Location',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              isDense: true,
                              iconSize: 28,
                              iconEnabledColor: Colors.amber,
                              items: locList.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['name']),
                                  value: item['id'].toString(),
                                );
                              }).toList(),
                              isExpanded: false,
                              value: selectedLoc, // == "" ? "" : selectedTxn,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLoc = newValue!;
                                  // print('transfer type: $transferType');
                                });
                              },
                            ),
                          ),
                        );
                      },
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
                              title: 'SAVE',
                              backgroundColor: Colors.amber,
                              textColor: Colors.black,
                              onPressed: () {
                                saveData();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> saveData() async {
    if (itemSNKey.currentState?.validate() != null ||
        itemQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Item Quantity cannot be empty');
    } else if (selectedReason == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Reason Code');
    } else if (selectedLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select item location');
    } else {
      if (tracking == "2") {
        DBCountItem()
            .createCountItem(CountItem(
          itemInvId: selectedInvtry,
          itemSerialNo: itemSNController.text,
          itemReason: selectedReason,
          itemLocation: selectedLoc,
        ))
            .then((value) {
          // SuccessDialog.showSuccessDialog(context, 'Item Save');
          showSuccess('Item Save');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.countItemList));
        });
      } else {
        DBCountNonItem()
            .createCountNonItem(CountNonItem(
          itemInvId: selectedInvtry,
          nonTracking: itemQtyController.text,
          itemReason: selectedReason,
          itemLocation: selectedLoc,
        ))
            .then((value) {
          // SuccessDialog.showSuccessDialog(context, 'Item Save');
          showSuccess('Item Save');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.countItemList));
        });
      }
    }
  }
}
