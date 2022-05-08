import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/outgoing/rv/rv_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_custReturn.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/master/master_supplier_db.dart';
import 'package:stms/data/local_db/outgoing/rv/rv_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/rv/rv_scanItem.dart';

import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/wrapper.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class RvCreateView extends StatefulWidget {
  final Function changeView;

  const RvCreateView({Key? key, required this.changeView}) : super(key: key);

  @override
  _RvCreateViewState createState() => _RvCreateViewState();
}

class _RvCreateViewState extends State<RvCreateView> {
  DateTime date = DateTime.now();
  var getCr = CustReturnService();
  List crList = [];
  List vendorList = [];
  List locList = [];
  List txnType = [
    {"id": "1", "name": "Replacement"}
  ];

  var formatDate,
      selectedTxn = "1",
      selectedCr,
      selectedvendor,
      selectedLoc,
      selectedItem,
      selectedLocDoc,
      vendorId;
  late TextEditingController rvDateController;

  @override
  void initState() {
    super.initState();

    getCrList();
    getCommon();
    formatDate = DateFormat('yyyy-MM-dd kk:mm:ss')
        .format(date); //DateFormat('yyyy-MM-dd kk:mm:ss')
    rvDateController = TextEditingController(text: formatDate);
    removeListItem();
  }

  getCrList() {
    var token = Storage().token;
    getCr.getCrList(token).then((value) {
      if (value.length == 0) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          // crList = value;
          // print('cr list value: $crList');
          crList = value.where((w) => w['status'] == '2').toList();
          crList.sort((a, b) => a["transaction_no"]
              .toLowerCase()
              .compareTo(b["transaction_no"].toLowerCase()));
        });
      }
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBReturnVendorItem().deleteAllRvItem();
    DBReturnVendorNonItem().deleteAllRvNonItem();

    prefs.remove('saveRV');
  }

  getCommon() {
    DBMasterSupplier().getAllMasterSupplier().then((value) {
      // print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download vendor file at master page first');
      } else {
        setState(() {
          vendorList = value;
        });
      }
    });

    DBMasterLocation().getAllMasterLoc().then((value) {
      // print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download location file at master page first');
      } else {
        setState(() {
          locList = value;
        });
      }
    });
  }

  getSelectedLocation(String selectedCr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = Storage().token;
    getCr.getCrList(token).then((value) {
      setState(() {
        selectedLocDoc = value.firstWhereOrNull(
            (element) => element['transaction_no'] == selectedCr);

        print('selected location: ${selectedLocDoc['location_id']}');
        print('Cr id: ${selectedLocDoc['rc_id']}');

        prefs.setString('selectedCr', selectedLocDoc['rc_id']);
        selectedLoc = selectedLocDoc['location_id'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Container(
          height: height * 0.85,
          child: Column(
            children: [
              StmsInputField(
                controller: rvDateController,
                hint: 'Date',
                readOnly: true,
                validator: Validator.valueExists,
              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Transaction Type',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: false,
                    child: new DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: DropdownButton<String>(
                            isDense: true,
                            iconSize: 28,
                            iconEnabledColor: Colors.amber,
                            items: txnType.map((item) {
                              return new DropdownMenuItem(
                                child: Container(
                                  width: width * 0.8,
                                  child: Text(
                                    item['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                value: item['id'].toString(),
                              );
                            }).toList(),
                            isExpanded: false,
                            value: selectedTxn,
                            onChanged: null
                            // (String? newValue) {
                            //   setState(() {
                            //     selectedTxn = newValue!;
                            //   });
                            // },
                            ),
                      ),
                    ),
                  );
                },
              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Customer Return Document No.',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: false,
                    child: new DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: DropdownButton<String>(
                          isDense: true,
                          iconSize: 28,
                          iconEnabledColor: Colors.amber,
                          items: crList.map((item) {
                            return new DropdownMenuItem(
                              child: Container(
                                width: width * 0.8,
                                child: Text(
                                  item['transaction_no'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value: item['transaction_no'].toString(),
                            );
                          }).toList(),
                          isExpanded: false,
                          value: selectedCr,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCr = newValue!;
                              getSelectedLocation(selectedCr);
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Vendor',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: false,
                    child: SearchChoices.single(
                      padding: 0,
                      displayClearIcon: false,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.amber,
                        size: 28,
                      ),
                      // iconEnabledColor: Colors.amberAccent,
                      iconDisabledColor: Colors.grey[350],
                      items: vendorList.map((item) {
                        return new DropdownMenuItem(
                          child: Text(
                            item['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: item['name'],
                        );
                      }).toList(),
                      value: selectedvendor,
                      onChanged: (value) {
                        setState(() {
                          selectedvendor = value;
                          var venId = vendorList.firstWhereOrNull(
                              (element) => element['name'] == value);
                          vendorId = venId['id'];
                        });
                      },
                      isExpanded: true,
                      searchInputDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      underline: Container(
                        height: 0,
                        padding: EdgeInsets.zero,
                      ),
                      selectedValueWidgetFn: (item) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(0),
                          child: Text(
                            item.toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // FormField<String>(
              //   builder: (FormFieldState<String> state) {
              //     return InputDecorator(
              //       decoration: InputDecoration(
              //         labelText: 'Vendor',
              //         errorText: state.hasError ? state.errorText : null,
              //       ),
              //       isEmpty: false,
              //       child: new DropdownButtonHideUnderline(
              //         child: ButtonTheme(
              //           child: DropdownButton<String>(
              //             isDense: true,
              //             iconSize: 28,
              //             iconEnabledColor: Colors.amber,
              //             items: vendorList.map((item) {
              //               return new DropdownMenuItem(
              //                 child: Container(
              //                   width: width * 0.8,
              //                   child: Text(
              //                     item['name'],
              //                     overflow: TextOverflow.ellipsis,
              //                   ),
              //                 ),
              //                 value: item['id'].toString(),
              //               );
              //             }).toList(),
              //             isExpanded: false,
              //             value: selectedvendor, // == "" ? "" : selectedTxn,
              //             onChanged: (String? newValue) {
              //               setState(() {
              //                 selectedvendor = newValue!;
              //                 // print('transfer type: $transferType');
              //               });
              //             },
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              // ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: false,
                    child: new DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: DropdownButton<String>(
                          isDense: true,
                          iconSize: 28,
                          iconEnabledColor: Colors.amber,
                          items: locList.map((item) {
                            return new DropdownMenuItem(
                              child: Container(
                                width: width * 0.8,
                                child: Text(
                                  item['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value: item['id'].toString(),
                            );
                          }).toList(),
                          isExpanded: false,
                          value: selectedLoc, // == "" ? "" : selectedTxn,
                          onChanged: null,
                          // (String? newValue) {
                          //   setState(() {
                          //     selectedLoc = newValue!;
                          //     // print('transfer type: $transferType');
                          //   });
                          // },
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: height*0.08,
                    child: StmsStyleButton(
                      title: 'ADD ITEM',
                      backgroundColor: Colors.amber,
                      textColor: Colors.black,
                      onPressed: () async {
                        createVendorReplace();
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createVendorReplace() async {
    widget.changeView(changeType: ViewChangeType.Forward);
    if (selectedCr == null) {
      ErrorDialog.showErrorDialog(
          context, 'Please select Customer Return Doc. No.');
    } else if (selectedvendor == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Vendor');
    } else if (selectedLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Location');
    } else {
      // print('date: ${crDateController.text}');
      // print('txn type: $selectedTxn');
      // print('vendor: $selectedvendor');

      var s = json.encode(ReturnVendor(
        rvDate: rvDateController.text,
        txnType: selectedTxn,
        crDoc: selectedCr,
        rvVendor: vendorId,
        rvLocation: selectedLoc,
      ));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('saveRV', s);

      //   // print('save ai value: $s');

      Navigator.of(context).pushNamed(StmsRoutes.rvItemList).then((value) {
        setState(() {
          selectedCr = null;
          selectedvendor = null;
          selectedLoc = null;
        });
      });
    }
  }
}
