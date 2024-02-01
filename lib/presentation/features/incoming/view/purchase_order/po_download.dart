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

// Selection page, choose which Document and vendor
class _PoDownloadViewState extends State<PoDownloadView> {
  // Initialize variable
  var getPurchaseOrder = IncomingService();                                      // Link variable to server data
  var selectedVendor,
      selectedPo,
      poTotalItem;

  // Initialize list
  List vendorList = [];
  List poList = [];

  // Initialize function
  @override
  void initState() {
    super.initState();

    getVendorList();                                                             // Call getVendorList function on page refresh
    removeListItem();                                                            // Call removeListItem function on page refresh
  }

  // Function for calling data from Master Page
  getVendorList() {
    DBMasterSupplier().getAllMasterSupplier().then((value) {
      // Check if got data from Master
      if (value == null) {
        // If no data
        ErrorDialog.showErrorDialog(
            context, 'Please Download Vendor at Master File First');
      } else {
        // If have data
        setState(() {
          vendorList = value;                                                    // Store data in vendorList variable
        });
      }
    });
  }

  // Function for calling data from server / API
  getPoList(String selectedVendor) {
    var token = Storage().token;                                                 // Create variable to store data temporarily
    getPurchaseOrder.getPurchaseOrderList(token).then((value) {
      // Check if got value in API
      if (value == []) {
        // If no value
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          print('selectedVen: $selectedVendor');

          // Store value in variable poList and do sorting
          poList = value.where((w) => w['supplier_id'] == selectedVendor).toList();
          poList.sort((a, b) => a["po_doc"].toLowerCase().compareTo(b["po_doc"].toLowerCase()));
          print('poList list new');
          print(poList);

        });
      }
    });
  }

  // Function for removing data
  removeListItem() async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBPoItem().deleteAllPoItem();                                                // Call delete from database for poItem
    DBPoNonItem().deleteAllPoNonItem();                                          // Call delete from database for poNonItem

    // Remove data
    prefs.remove('poReceiptType');
    prefs.remove('poId_info');
    prefs.remove('poLocation');
  }

  // UI layout
  @override
  Widget build(BuildContext context) {
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
                                  poTotalItem = null;
                                  getPoList(vendorId['id']);
                                  print('VENDOR: $vendorId');
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
                      // Go to savePO function
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

  // Function when press save Button
  Future<void> savePo() async {
    // Check if the drop down list is filled
    if (selectedPo == null) {
      // If no value in drop down list
      ErrorDialog.showErrorDialog(context, 'Please select Purchase Order');
    } else {
      // If have value in drop down list
      // SharedPreferences use to get and save selected data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('poID', selectedPo);                                       // Store poId sata
      removeListItem();                                                          // Remove function

      // Call server address class for get the data from API
      IncomingService().getPurchaseOrderItem().then((value) {
        setState(() {
          // Set variable to null to reset the value
          selectedVendor = null;
          selectedPo = null;
        });
        // Navigate to different class
        Navigator.of(context).pushNamed(StmsRoutes.poItemList);
      });
    }
  }
}
