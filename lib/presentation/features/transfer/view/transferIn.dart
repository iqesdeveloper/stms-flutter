import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/transfer/st_model.dart';
import 'package:stms/data/api/repositories/api_json/api_transfer.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/transfer/st_non_scanItem.dart';
import 'package:stms/data/local_db/transfer/st_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class TransferInView extends StatefulWidget {
  final Function changeView;

  const TransferInView({Key? key, required this.changeView}) : super(key: key);

  @override
  _TransferInViewState createState() => _TransferInViewState();
}

class _TransferInViewState extends State<TransferInView> {
  DateTime date = DateTime.now();
  List locList = [];
  List transList = [];
  List txnType = [
    {"id": "1", "name": "Transfer In"},
    {"id": "2", "name": "Transfer Out"}
  ];
  var formatDate,
      selectedTxn,
      selectedTransferDoc,
      selectedtoLoc,
      selectedfromLoc,
      trasnferDoc,
      transFromLoc,
      locationFromId,
      fromLocId,
      locationToId;
  // final format = DateFormat("yyyy-MM-dd");
  late TextEditingController stDateController;
  final TextEditingController stDocNoController = TextEditingController();

  final GlobalKey<StmsInputFieldState> stDocNoKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    formatDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(date);
    stDateController = TextEditingController(text: formatDate);
    selectedTxn = Storage().transfer;
    removeListItem();
    getCommon();
    getTransferList();
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBStockTransItem().deleteAllStItem();
    DBStockTransNonItem().deleteAllStNonItem();

    prefs.remove('saveST');
  }

  getCommon() {
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
  }

  getTransferList() {
    var token = Storage().token;
    StockTransService().getTransferList(token).then((value) {
      if (value == []) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          //   prList = value;
          // print('pr list value: $prList');

          transList = value
              .where((w) => w['sti_type'] == '2' && w['status'] == '2') //
              .toList();
          // print('po new list value: $item');
          transList.sort((a, b) =>
              a["sti_doc"].toLowerCase().compareTo(b["sti_doc"].toLowerCase()));
        });
      }
    });
  }

  getTransferFromLoc(selectedTransferDoc) async {
    var token = Storage().token;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    StockTransService().getTransferList(token).then((value) {
      if (value == []) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          var newtransList = value.where((w) => w['sti_type'] == '2').toList();
          // print('po new list value: $item');
          transFromLoc = newtransList.firstWhereOrNull(
              (element) => element['sti_doc'] == selectedTransferDoc);

          print('transfer From loc: ${transFromLoc['to_location']}');
          if (Storage().transfer == '1') {
            var locName = locList.firstWhereOrNull(
                (element) => element['id'] == transFromLoc['to_location']);
            selectedfromLoc = locName['name'];
            fromLocId = locName['id'];
            prefs.setString('selectedTransfer', transFromLoc['sti_id']);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Container(
          height: height * 0.85,
          child: Column(
            children: [
              StmsInputField(
                controller: stDateController,
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
                              child: new Text(item['name']),
                              value: item['id'].toString(),
                            );
                          }).toList(),
                          isExpanded: false,
                          value: selectedTxn,
                          onChanged: null,
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
              Storage().transfer == '1'
                  ? FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Transfer Out Doc',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              child: DropdownButton<String>(
                                isDense: true,
                                iconSize: 28,
                                iconEnabledColor: Colors.amber,
                                items: transList.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(
                                      item['sti_doc'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    value: item['sti_doc'].toString(),
                                  );
                                }).toList(),
                                isExpanded: false,
                                value:
                                    selectedTransferDoc, // == "" ? "" : selectedTxn,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedTransferDoc = newValue!;
                                    // print('transfer type: $transferType');
                                    getTransferFromLoc(selectedTransferDoc);
                                  });
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(),
              Storage().transfer == '1'
                  ? FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'From Location',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: SearchChoices.single(
                            padding: 0,
                            displayClearIcon: false,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              // color: Colors.amber,
                              size: 28,
                            ),
                            iconEnabledColor: Colors.amber,
                            iconDisabledColor: Colors.grey[400],
                            items: locList.map((item) {
                              return new DropdownMenuItem(
                                child: Text(
                                  item['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                                value: item['name'],
                              );
                            }).toList(),
                            value: selectedfromLoc,
                            onChanged: null,
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
                    )
                  : FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'From Location',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: SearchChoices.single(
                            padding: 0,
                            displayClearIcon: false,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              // color: Colors.amber,
                              size: 28,
                            ),
                            iconEnabledColor: Colors.amber,
                            iconDisabledColor: Colors.grey[400],
                            items: locList.map((item) {
                              return new DropdownMenuItem(
                                child: Text(
                                  item['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                                value: item['name'],
                              );
                            }).toList(),
                            value: selectedfromLoc,
                            onChanged: (value) {
                              setState(() {
                                selectedfromLoc = value;
                                var locId = locList.firstWhereOrNull(
                                    (element) => element['name'] == value);
                                locationFromId = locId['id'];
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
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'To Location',
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
                      value: selectedtoLoc,
                      onChanged: (value) {
                        setState(() {
                          selectedtoLoc = value;
                          var locToId = locList.firstWhereOrNull(
                              (element) => element['name'] == value);
                          locationToId = locToId['id'];
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
                          createStockTransfer();
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

  Future<void> createStockTransfer() async {
    if (selectedTxn == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Transaction Type');
    } else if (Storage().transfer == '1' && selectedTransferDoc == null) {
      ErrorDialog.showErrorDialog(
          context, 'Please select Transfer Out Doc No.');
    } else if (selectedfromLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select From Location');
    } else if (selectedtoLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select To Location');
    } else if (selectedfromLoc == selectedtoLoc) {
      ErrorDialog.showErrorDialog(context, 'Location cannot be same');
    } else {
      if (Storage().transfer == '1') {
        trasnferDoc = selectedTransferDoc;
      } else {
        trasnferDoc = "";
      }
      var s = json.encode(StockTransfer(
        stiDate: stDateController.text,
        stType: selectedTxn,
        transOutDoc: trasnferDoc,
        toLoc: locationToId,
        fromLoc: Storage().transfer == '1' ? fromLocId : locationFromId,
      ));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('saveST', s);

      print('save transfer value: $s');

      Navigator.of(context).pushNamed(StmsRoutes.stItemList).then((value) {
        setState(() {
          selectedTransferDoc = null;
          selectedfromLoc = null;
          selectedtoLoc = null;
        });
      });
    }
  }
}
