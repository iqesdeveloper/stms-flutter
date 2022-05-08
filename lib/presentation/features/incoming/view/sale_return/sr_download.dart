import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/repositories/api_json/api_in_saleReturn.dart';
import 'package:stms/data/local_db/incoming/sr/sr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/sr/sr_scanItem_db.dart';
import 'package:stms/data/local_db/master/master_customer_db.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SrDownloadView extends StatefulWidget {
  final Function changeView;

  const SrDownloadView({Key? key, required this.changeView}) : super(key: key);

  @override
  _SrDownloadViewState createState() => _SrDownloadViewState();
}

class _SrDownloadViewState extends State<SrDownloadView> {
  var getSaleReturn = SaleReturnService();
  List locList = [];
  List custList = [];
  List srList = [];
  var selectedLoc, selectedCust, selectedSr;

  @override
  void initState() {
    super.initState();

    getCommon();
    removeListItem();
  }

  getCommon() {
    DBMasterCustomer().getAllMasterCust().then((value) {
      print('value cust: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download customer file at master page first');
      } else {
        setState(() {
          custList = value;
        });
      }
    });
  }

  getSaleReturnList(String selectedCust) {
    print('selectedCust id: $selectedCust');
    var token = Storage().token;
    getSaleReturn.getSrList(token).then((value) {
      setState(() {
        // srList = value;
        print('sr list value: $srList');
        srList = value.where((w) => w['customer_id'] == selectedCust).toList();
        srList.sort((a, b) =>
            a["sr_doc"].toLowerCase().compareTo(b["sr_doc"].toLowerCase()));
      });
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBSaleReturnItem().deleteAllSrItem();
    DBSaleReturnNonItem().deleteAllSrNonItem();

    prefs.remove('sr_info');
    prefs.remove('srLoc');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    decoration: ShapeDecoration(
                      shape: ContinuousRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Please Choose Customer',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: SearchChoices.single(
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
                                      (element) =>
                                          element['name'] == selectedCust);
                                  selectedSr = null;
                                  getSaleReturnList(custId['id']);
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
                              padding: 0,
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
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      shape: ContinuousRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Please Choose Sales Return File',
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
                                  items: srList.map((item) {
                                    return new DropdownMenuItem(
                                      child: Container(
                                        width: width * 0.7,
                                        child: Text(
                                          item['sr_doc'],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      value: item['sr_id'].toString(),
                                    );
                                  }).toList(),
                                  isExpanded: false,
                                  value: selectedSr == "" ? "" : selectedSr,
                                  onChanged: selectedCust == null
                                      ? null
                                      : (String? newValue) {
                                          setState(() {
                                            selectedSr = newValue;
                                          });
                                        },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height*0.08,
                child: StmsStyleButton(
                  title: 'SELECT',
                  backgroundColor: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () {
                    // Navigator.of(context)
                    //     .pushNamed(StmsRoutes.purchaseOrderItem);
                    saveSr();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveSr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('srID', selectedSr!);
    removeListItem();

    SaleReturnService().getSrItem().then((value) {
      setState(() {
        selectedCust = null;
        selectedSr = null;
        Navigator.of(context).pushNamed(StmsRoutes.srItemList);
      });
    });
  }
}
