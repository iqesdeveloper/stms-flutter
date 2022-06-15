import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/repositories/api_json/api_in_po.dart';
import 'package:stms/data/local_db/incoming/po/po_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/po/po_scanItem_db.dart';
import 'package:stms/data/local_db/master/master_supplier_db.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoDownloadView extends StatefulWidget {
  final Function changeView;

  const PoDownloadView({Key? key, required this.changeView}) : super(key: key);

  @override
  _PoDownloadViewState createState() => _PoDownloadViewState();
}

class _PoDownloadViewState extends State<PoDownloadView> {
  var getPurchaseOrder = IncomingService();
  List vendorList = [];
  List poList = [];
  var testList;
  var selectedVendor, selectedPo;

  // upon start this page, it will run the vendorList function
  // vendorList function calls the item contain vendor in API
  @override
  void initState() {
    super.initState();

    getVendorList();
    // getPoList();
    removeListItem();
  }

  // vendor obtained from the portal and store into vendorList variable
  // vendorList variable holds the content and will display under drop down menus
  getVendorList() {
    DBMasterSupplier().getAllMasterSupplier().then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please Download Vendor at Master File First');
      } else {
        setState(() {
          vendorList = value;
          testList = List<Map<String, dynamic>>.of(value);
          // vendorList = value.map((item) => Supplier.fromJson(item)).toList();
          // print('vendor list value: $vendorList');
        });
      }
    });
  }

  // get the PO from the API and store into the poList variable
  // poList variable holds the content and will display under drop down menu
  getPoList(String selectedVendor) {
    var token = Storage().token;
    getPurchaseOrder.getPurchaseOrderList(token).then((value) {
      if (value == []) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          print('selectedVen: $selectedVendor');

          poList =
              value.where((w) => w['supplier_id'] == selectedVendor).toList();
          poList.sort((a, b) =>
              a["po_doc"].toLowerCase().compareTo(b["po_doc"].toLowerCase()));
          print('poList list new');
          print(poList);
        });
      }
    });
  }

  // remove item
  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBPoItem().deleteAllPoItem();
    DBPoNonItem().deleteAllPoNonItem();

    prefs.remove('poReceiptType');
    prefs.remove('poId_info');
    prefs.remove('poLocation');
  }

  // UI layout
  @override
  Widget build(BuildContext context) {
    // var width = MediaQuery.of(context).size.width;
    // var height = MediaQuery.of(context).size.height;

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
                  // The vendor drop down section
                  Container(
                    // design look of the drop down widget
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
                        // The function of the drop down widget
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // The text of the drop down menu
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Please Select Vendor',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            // Drop down arrow
                            child: SearchChoices.single(
                              displayClearIcon: false,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.amber,
                                size: 28,
                              ),
                              // iconEnabledColor: Colors.amberAccent,
                              iconDisabledColor: Colors.grey[350],
                              // using the vendorList content to map how many vendor list is present in the API
                              items: vendorList.map((item) {
                                return new DropdownMenuItem(
                                  // Only call the name of the vendor
                                  child: Text(
                                    item['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: item['name'],
                                );
                              }).toList(),
                              // calling the API and comparing if it return empty of value
                              value: selectedVendor,
                              onChanged: (value) {
                                setState(() {
                                  selectedVendor = value;
                                  print('selected vendor: $selectedVendor');
                                  var vendorId = vendorList.firstWhereOrNull(
                                      (element) =>
                                          element['name'] == selectedVendor);
                                  selectedPo = null;
                                  getPoList(vendorId['id']);
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
                  // The PoList drop down section
                  Container(
                    // design look of the drop down widget
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
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        // The function of the drop down widget
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // The text of the drop down menu
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Please Choose Purchase Order',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: new DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                child: DropdownButton<String>(
                                  // dropdownColor: Colors.red,
                                  isDense: true,
                                  iconSize: 28,
                                  iconEnabledColor: Colors.amber,
                                  // using the vendorList content to map how many vendor list is present in the API
                                  items: poList.map((item) {
                                    return new DropdownMenuItem(
                                      child: new Text(
                                        item['po_doc'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      value: item['po_id'].toString(),
                                    );
                                  }).toList(),
                                  // calling the API and comparing if it return empty of value
                                  isExpanded: false,
                                  value: selectedPo == "" ? "" : selectedPo,
                                  onChanged: selectedVendor != null
                                      ? (String? newValue) {
                                          setState(() {
                                            selectedPo = newValue!;
                                          });
                                        }
                                      : null,
                                  underline: Container(
                                    height: 0,
                                  ),
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
          // Save Button
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
                      savePo();
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

  // the save function, calling and get the selected option to the next section
  Future<void> savePo() async {
    if (selectedPo == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Purchase Order');
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('poID', selectedPo);
      removeListItem();

      IncomingService().getPurchaseOrderItem().then((value) {
        setState(() {
          selectedVendor = null;
          selectedPo = null;
        });
        Navigator.of(context).pushNamed(StmsRoutes.poItemList);
      });
    }
  }
}
