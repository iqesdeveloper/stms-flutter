import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/outgoing/rric/rric_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_custReturn.dart';
import 'package:stms/data/api/repositories/api_json/api_in_vsr.dart';
import 'package:stms/data/local_db/master/master_customer_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/outgoing/rric/rric_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/rric/rric_scanItem.dart';

import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/wrapper.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class RcCreateView extends StatefulWidget {
  final Function changeView;

  const RcCreateView({Key? key, required this.changeView}) : super(key: key);

  @override
  _RcCreateViewState createState() => _RcCreateViewState();
}

class _RcCreateViewState extends State<RcCreateView> {
  DateTime date = DateTime.now();
  var getVsr = VendorReplaceService();
  var getCr = CustReturnService();
  List vsrList = [];
  List crList = [];
  List custList = [];
  List locList = [];
  List txnType = [
    {"id": "1", "name": "Replacement"},
    {"id": "2", "name": "Repair"}
  ];

  var formatDate,
      selectedTxn,
      selectedVsr,
      selectedCust,
      selectedLoc,
      selectedItem,
      selectedCr,
      selectedLocDoc,
      customerId,
      selectedCustId;
  late TextEditingController rcDateController;

  @override
  void initState() {
    super.initState();

    getVsrList();
    getCrList();
    getCommon();
    formatDate = DateFormat('yyyy-MM-dd kk:mm:ss')
        .format(date); //DateFormat('yyyy-MM-dd kk:mm:ss')
    rcDateController = TextEditingController(text: formatDate);
    removeListItem();
  }

  getVsrList() {
    var token = Storage().token;
    getVsr.getVsrList(token).then((value) {
      if (value.length == 0) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          // vsrList = value;
          vsrList = value.where((w) => w['status'] == '2').toList();
          // print('vsr list value: $vsrList');
          vsrList.sort((a, b) => a["replace_supplier_transaction_id"]
              .toLowerCase()
              .compareTo(b["replace_supplier_transaction_id"].toLowerCase()));
        });
      }
    });
  }

  getSelectedVsr(String selectedVsr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = Storage().token;
    getVsr.getVsrList(token).then((value) {
      setState(() {
        selectedLocDoc = value.firstWhereOrNull((element) =>
            element['replace_supplier_transaction_id'] == selectedVsr);

        print('selected location: ${selectedLocDoc['location_id']}');
        print('Vsr id: ${selectedLocDoc['rs_id']}');

        prefs.setString('selectedVsr', selectedLocDoc['rs_id']);
        selectedLoc = selectedLocDoc['location_id'];
      });
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBReplaceCustItem().deleteAllRricItem();
    DBReplaceCustNonItem().deleteAllRricNonItem();

    prefs.remove('saveRC');
  }

  getCommon() {
    DBMasterCustomer().getAllMasterCust().then((value) {
      // print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download customer file at master page first');
      } else {
        setState(() {
          custList = value;
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

  getCrList() {
    var token = Storage().token;
    getCr.getCrList(token).then((value) {
      if (value.length == 0) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          crList = value.where((w) => w['status'] == '2').toList();
          crList.sort((a, b) => a["transaction_no"]
              .toLowerCase()
              .compareTo(b["transaction_no"].toLowerCase()));
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

        // print('selected location: ${selectedLocDoc['location_id']}');
        // print('selected cust: ${selectedLocDoc['customer_id']}');
        // print('Cr id: ${selectedLocDoc['rc_id']}');

        prefs.setString('selectedCr', selectedLocDoc['rc_id']);
        prefs.setString('crTxnNo', selectedLocDoc['transaction_no']);

        selectedLoc = selectedLocDoc['location_id'];

        var custName = custList.firstWhereOrNull(
            (element) => element['id'] == selectedLocDoc['customer_id']);
        selectedCust = custName['name'];
        selectedCustId = selectedLocDoc['customer_id'];
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
                controller: rcDateController,
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
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTxn = newValue!;
                              selectedCust = null;
                              selectedLoc = null;
                              selectedCr = null;
                              selectedVsr = null;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              selectedTxn == '1'
                  ? FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Vendor Stock Replacement Doc No.',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              child: DropdownButton<String>(
                                isDense: true,
                                iconSize: 28,
                                iconEnabledColor: Colors.amber,
                                items: vsrList.map((item) {
                                  return new DropdownMenuItem(
                                    child: Container(
                                      width: width * 0.8,
                                      child: Text(
                                        item['replace_supplier_transaction_id'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    value:
                                        item['replace_supplier_transaction_id']
                                            .toString(),
                                  );
                                }).toList(),
                                isExpanded: false,
                                value: selectedVsr,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedVsr = newValue!;
                                    getSelectedVsr(selectedVsr);
                                  });
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : selectedTxn == '2'
                      ? FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Customer Return Document No.',
                                errorText:
                                    state.hasError ? state.errorText : null,
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
                                        value:
                                            item['transaction_no'].toString(),
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
                        )
                      : Container(),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Customer',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: false,
                    child: SearchChoices.single(
                      padding: 0,
                      displayClearIcon: false,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 28,
                      ),
                      iconEnabledColor: Colors.amber,
                      iconDisabledColor: Colors.grey[400],
                      items: custList.map((item) {
                        return new DropdownMenuItem(
                          child: Text(
                            item['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: item['name'],
                        );
                      }).toList(),
                      value: selectedCust,
                      onChanged: selectedTxn == '2'
                          ? null
                          : (value) {
                              setState(() {
                                selectedCust = value;
                                var custId = custList.firstWhereOrNull(
                                    (element) => element['name'] == value);
                                customerId = custId['id'];
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
              //         labelText: 'Customer',
              //         errorText: state.hasError ? state.errorText : null,
              //       ),
              //       isEmpty: false,
              //       child: new DropdownButtonHideUnderline(
              //         child: ButtonTheme(
              //           child: DropdownButton<String>(
              //             isDense: true,
              //             iconSize: 28,
              //             iconEnabledColor: Colors.amber,
              //             items: custList.map((item) {
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
              //             value: selectedCust, // == "" ? "" : selectedTxn,
              //             onChanged: selectedTxn == '2'
              //                 ? null
              //                 : (String? newValue) {
              //                     setState(() {
              //                       selectedCust = newValue!;
              //                       // print('transfer type: $transferType');
              //                     });
              //                   },
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: ButtonTheme(
                      minWidth: 200,
                      height: 50,
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
    if (selectedTxn == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Transaction Type');
    } else if (selectedTxn == '1' && selectedVsr == null) {
      ErrorDialog.showErrorDialog(
          context, 'Please select Vendor Stock Replacement Doc. No.');
    } else if (selectedCust == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Customer');
    } else if (selectedLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Location');
    } else {
      // print('date: ${crDateController.text}');
      // print('txn type: $selectedTxn');
      // print('vendor: $selectedvendor');

      var s = json.encode(ReplaceCust(
        rcDate: rcDateController.text,
        txnType: selectedTxn,
        vsrDoc: selectedTxn == '1' ? selectedVsr : "",
        rcCust: selectedTxn == '2' ? selectedCustId : customerId,
        rcLocation: selectedLoc,
        crDoc: selectedTxn == '2' ? selectedCr : "",
      ));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('saveRRIC', s);

      removeListItem();

      //   // print('save ai value: $s');

      Navigator.of(context).pushNamed(StmsRoutes.rcItemList).then((value) {
        setState(() {
          selectedTxn = null;
          selectedVsr = null;
          selectedCust = null;
          selectedLoc = null;
        });
      });
    }
  }
}
