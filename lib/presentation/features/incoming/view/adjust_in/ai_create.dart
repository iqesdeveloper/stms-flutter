import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/ai/ai_model.dart';
import 'package:stms/data/local_db/incoming/adjust_in/ai_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/adjust_in/ai_scanItem.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class AiCreateView extends StatefulWidget {
  final Function changeView;

  const AiCreateView({Key? key, required this.changeView}) : super(key: key);

  @override
  _AiCreateViewState createState() => _AiCreateViewState();
}

class _AiCreateViewState extends State<AiCreateView> {
  DateTime date = DateTime.now();
  List locList = [];
  List txnType = [
    {"id": "1", "name": "Adjustment In"},
    {"id": "2", "name": "Variance In"}
  ];

  var formatDate, selectedTxn, selectedLoc, selectedItem, locationId;
  late TextEditingController iaDateController;
  final TextEditingController iabatchIDController = TextEditingController();

  final GlobalKey<StmsInputFieldState> iabatchIDKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getCommon();
    formatDate = DateFormat('yyyy-MM-dd kk:mm:ss')
        .format(date); //DateFormat('yyyy-MM-dd kk:mm:ss')
    iaDateController = TextEditingController(text: formatDate);
    removeListItem();
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBAdjustInItem().deleteAllAiItem();
    DBAdjustInNonItem().deleteAllAiNonItem();

    prefs.remove('saveAI');
  }

  getCommon() {
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
    iabatchIDController.clear();
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
                controller: iaDateController,
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
                      labelText: 'Item Location',
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
                          createAdjustIn();
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

  Future<void> createAdjustIn() async {
    if (selectedTxn == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Transaction Type');
    } else if (selectedLoc == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Location');
    } else {
      var s = json.encode(AdjustIn(
        iaTxnType: selectedTxn,
        iaDate: iaDateController.text,
        location: locationId,
      ));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('saveAI', s);

      // print('save ai value: $s');

      Navigator.of(context).pushNamed(StmsRoutes.aiItemList).then((value) {
        setState(() {
          selectedTxn = null;
          selectedLoc = null;
        });
      });
    }
  }
}
