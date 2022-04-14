import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/incoming/vsr/vsr_model.dart';
import 'package:stms/data/api/repositories/api_json/api_out_rv.dart';
import 'package:stms/data/local_db/incoming/vsr/vsr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/vsr/vsr_scanItem.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/master/master_supplier_db.dart';

import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/wrapper.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class VsrCreateView extends StatefulWidget {
  final Function changeView;

  const VsrCreateView({Key? key, required this.changeView}) : super(key: key);

  @override
  _VsrCreateViewState createState() => _VsrCreateViewState();
}

class _VsrCreateViewState extends State<VsrCreateView> {
  DateTime date = DateTime.now();
  var getRv = ReturnVendorService();
  List rvList = [];
  List vendorList = [];
  List locList = [];
  List txnType = [
    {"id": "1", "name": "Replacement Supplier"}
  ];

  var formatDate,
      selectedTxn = "1",
      selectedvendor,
      selectedRv,
      selectedLoc,
      selectedItem,
      selectedVendorName,
      locationId;
  late TextEditingController vsrDateController;

  @override
  void initState() {
    super.initState();

    getRvList();
    getCommon();
    formatDate = DateFormat('yyyy-MM-dd kk:mm:ss')
        .format(date); //DateFormat('yyyy-MM-dd kk:mm:ss')
    vsrDateController = TextEditingController(text: formatDate);
    removeListItem();
  }

  getRvList() {
    var token = Storage().token;
    getRv.getRvList(token).then((value) {
      if (value.length == 0) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          // rvList = value;
          // print('rv list value: $rvList');
          rvList = value.where((w) => w['status'] == '2').toList();
          rvList.sort((a, b) =>
              a["rst_id"].toLowerCase().compareTo(b["rst_id"].toLowerCase()));
        });
      }
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBVendorReplaceItem().deleteAllVsrItem();
    DBVendorReplaceNonItem().deleteAllVsrNonItem();

    prefs.remove('saveVSR');
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

  Future<void> getSelectedVendor(String selectedRv) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = Storage().token;
    getRv.getRvList(token).then((value) {
      setState(() {
        selectedVendorName = value
            .firstWhereOrNull((element) => element['rst_id'] == selectedRv);

        print('selected vendor: ${selectedVendorName['supplier_id']}');
        print('Rv id: ${selectedVendorName['out_rs_id']}');

        prefs.setString('selectedRv', selectedVendorName['out_rs_id']);
        selectedvendor = selectedVendorName['supplier_id'];
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
                controller: vsrDateController,
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
                      labelText: 'Return to Vendor Document No.',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: false,
                    child: new DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: DropdownButton<String>(
                          isDense: true,
                          iconSize: 28,
                          iconEnabledColor: Colors.amber,
                          items: rvList.map((item) {
                            return new DropdownMenuItem(
                              child: Container(
                                width: width * 0.8,
                                child: Text(
                                  item['rst_id'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value: item['rst_id'].toString(),
                            );
                          }).toList(),
                          isExpanded: false,
                          value: selectedRv,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRv = newValue!;
                              getSelectedVendor(selectedRv);
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
                    child: new DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: DropdownButton<String>(
                          isDense: true,
                          iconSize: 28,
                          iconEnabledColor: Colors.amber,
                          items: vendorList.map((item) {
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
                          value: selectedvendor, // == "" ? "" : selectedTxn,
                          onChanged: null,
                          // (String? newValue) {
                          //   setState(() {
                          //     selectedvendor = newValue!;
                          //     // print('transfer type: $transferType');
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
                      labelText: 'Location',
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
                      items: locList.map((item) {
                        return new DropdownMenuItem(
                          child: Text(
                            item['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: item['name'],
                        );
                      }).toList(),
                      value: selectedLoc,
                      onChanged: (value) {
                        setState(() {
                          selectedLoc = value;
                          var locId = locList.firstWhereOrNull(
                              (element) => element['name'] == value);
                          locationId = locId['id'];
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
    if (selectedRv == null) {
      ErrorDialog.showErrorDialog(
          context, 'Please select Return to Vendor Doc. No.');
    } else if (selectedvendor == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Vendor');
    } else if (selectedLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Location');
    } else {
      // print('date: ${crDateController.text}');
      // print('txn type: $selectedTxn');
      // print('vendor: $selectedvendor');

      var s = json.encode(
        VendorReplace(
          vsrDate: vsrDateController.text,
          returnDoc: selectedRv,
          vsrVendor: selectedvendor,
          vsrLoc: locationId,
        ),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('saveVSR', s);

      print('save vsr value: $s');

      Navigator.of(context).pushNamed(StmsRoutes.vsrItemList).then((value) {
        setState(() {
          selectedRv = null;
          selectedvendor = null;
          selectedLoc = null;
        });
      });
    }
  }
}
