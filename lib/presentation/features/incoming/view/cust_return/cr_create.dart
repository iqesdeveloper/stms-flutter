import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/cr/cr_model.dart';

import 'package:stms/data/local_db/incoming/cr/cr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/cr/cr_scanItem.dart';
import 'package:stms/data/local_db/master/master_customer_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/wrapper.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class CrCreateView extends StatefulWidget {
  final Function changeView;

  const CrCreateView({Key? key, required this.changeView}) : super(key: key);

  @override
  _CrCreateViewState createState() => _CrCreateViewState();
}

class _CrCreateViewState extends State<CrCreateView> {
  DateTime date = DateTime.now();
  List custList = [];
  List locList = [];
  List txnType = [
    {"id": "1", "name": "Customer Return"}
  ];

  var formatDate,
      selectedTxn = "1",
      selectedCust,
      selectedLoc,
      selectedItem,
      customerId,
      locationId;
  late TextEditingController crDateController;

  @override
  void initState() {
    super.initState();

    getCommon();
    formatDate = DateFormat('yyyy-MM-dd kk:mm:ss')
        .format(date); //DateFormat('yyyy-MM-dd kk:mm:ss')
    crDateController = TextEditingController(text: formatDate);
    removeListItem();
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBCustReturnItem().deleteAllCrItem();
    DBCustReturnNonItem().deleteAllCrNonItem();

    prefs.remove('saveCR');
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
                controller: crDateController,
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
                      labelText: 'Customer',
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
                      onChanged: (value) {
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
                          createCustReturn();
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

  Future<void> createCustReturn() async {
    widget.changeView(changeType: ViewChangeType.Forward);
    if (selectedCust == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Customer');
    } else if (selectedLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Location');
    } else {
      var s = json.encode(
        CustReturn(
          crDate: crDateController.text,
          crCustomer: customerId,
          crLoc: locationId,
        ),
      );
      print('cust Return: $s');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('saveCR', s);

      //   // print('save ai value: $s');

      Navigator.of(context).pushNamed(StmsRoutes.crItemList).then((value) {
        setState(() {
          selectedCust = null;
          selectedLoc = null;
        });
      });
    }
  }
}
