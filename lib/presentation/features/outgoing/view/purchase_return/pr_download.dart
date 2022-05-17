import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/repositories/api_json/api_out_purchaseReturn.dart';
import 'package:stms/data/local_db/master/master_supplier_db.dart';
import 'package:stms/data/local_db/outgoing/pr/pr_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/pr/pr_scanItem.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrDownloadView extends StatefulWidget {
  final Function changeView;

  const PrDownloadView({Key? key, required this.changeView}) : super(key: key);

  @override
  _PrDownloadViewState createState() => _PrDownloadViewState();
}

class _PrDownloadViewState extends State<PrDownloadView> {
  var getPurchaseReturn = PurchaseReturnService();
  List vendorList = [];
  List prList = [];
  var selectedVendor, selectedPr;

  @override
  void initState() {
    super.initState();

    getVendorList();
    removeListItem();
  }

  getVendorList() {
    DBMasterSupplier().getAllMasterSupplier().then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please Download Vendor at Master File First');
      } else {
        setState(() {
          vendorList = value;
          // print('vendor list value: $vendorList');
        });
      }
    });
  }

  getPurchaseReturnList(String selectedVendor) {
    var token = Storage().token;
    getPurchaseReturn.getPrList(token).then((value) {
      if (value == []) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          //   prList = value;
          // print('pr list value: $prList');

          prList =
              value.where((w) => w['supplier_id'] == selectedVendor).toList();
          // print('po new list value: $item');
          prList.sort((a, b) =>
              a["pr_doc"].toLowerCase().compareTo(b["pr_doc"].toLowerCase()));
        });
      }
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBPurchaseReturnItem().deleteAllPrItem();
    DBPurchaseReturnNonItem().deleteAllPrNonItem();
    prefs.remove('pr_info');
    prefs.remove('prLoc');
  }

  @override
  Widget build(BuildContext context) {
    // var width = MediaQuery.of(context).size.width;

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
                              labelText: 'Please Select Vendor',
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
                              items: vendorList.map((item) {
                                return new DropdownMenuItem(
                                  child: Text(
                                    item['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: item['name'],
                                );
                              }).toList(),
                              value: selectedVendor,
                              onChanged: (value) {
                                if (mounted)
                                  setState(() {
                                    selectedVendor = value;
                                    print('selected vendor: $selectedVendor');
                                    var vendorId = vendorList.firstWhereOrNull(
                                        (element) =>
                                            element['name'] == selectedVendor);
                                    selectedPr = null;
                                    getPurchaseReturnList(vendorId['id']);
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
                  // Container(
                  //   decoration: ShapeDecoration(
                  //     shape: ContinuousRectangleBorder(
                  //       side: BorderSide(
                  //         width: 1,
                  //         style: BorderStyle.solid,
                  //       ),
                  //       borderRadius: BorderRadius.all(
                  //         Radius.circular(5),
                  //       ),
                  //     ),
                  //   ),
                  //   margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                  //   child: FormField<String>(
                  //     builder: (FormFieldState<String> state) {
                  //       return Container(
                  //         padding: EdgeInsets.symmetric(horizontal: 5),
                  //         child: InputDecorator(
                  //           decoration: InputDecoration(
                  //             labelText: 'Please Choose Vendor',
                  //             errorText:
                  //                 state.hasError ? state.errorText : null,
                  //           ),
                  //           isEmpty: false,
                  //           child: new DropdownButtonHideUnderline(
                  //             child: ButtonTheme(
                  //               child: DropdownButton<String>(
                  //                 isDense: true,
                  //                 iconSize: 28,
                  //                 iconEnabledColor: Colors.amber,
                  //                 items: vendorList.map((item) {
                  //                   return new DropdownMenuItem(
                  //                     child: Container(
                  //                       width: width * 0.7,
                  //                       child: Text(
                  //                         item['name'],
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ),
                  //                     ),
                  //                     value: item['id'].toString(),
                  //                   );
                  //                 }).toList(),
                  //                 isExpanded: false,
                  //                 value: selectedVendor == ""
                  //                     ? ""
                  //                     : selectedVendor,
                  //                 onChanged: (String? newValue) {
                  //                   if (mounted)
                  //                     setState(() {
                  //                       selectedVendor = newValue;
                  //                       selectedPr = null;
                  //                       getPurchaseReturnList();
                  //                     });
                  //                 },
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
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
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Please Choose Purchase Return File',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: new DropdownButtonHideUnderline(
                              child: new DropdownButton<String>(
                                isDense: true,
                                iconSize: 28,
                                iconEnabledColor: Colors.amber,
                                items: prList.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(item['pr_doc']),
                                    value: item['pr_id'].toString(),
                                  );
                                }).toList(),
                                isExpanded: false,
                                value: selectedPr == "" ? "" : selectedPr,
                                onChanged: selectedVendor != null
                                    ? (String? newValue) {
                                        setState(() {
                                          selectedPr = newValue;
                                        });
                                      }
                                    : null,
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: ButtonTheme(
                  minWidth: 200,
                  height: 50,
                  child: StmsStyleButton(
                    title: 'SELECT',
                    backgroundColor: Colors.amber,
                    textColor: Colors.black,
                    onPressed: () {
                      // Navigator.of(context)
                      //     .pushNamed(StmsRoutes.purchaseOrderItem);
                      savePr();
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> savePr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('prID', selectedPr);
    removeListItem();

    PurchaseReturnService().getPrItem().then((value) {
      setState(() {
        selectedVendor = null;
        selectedPr = null;
      });
      Navigator.of(context).pushNamed(StmsRoutes.prItemList);
    });
  }
}
