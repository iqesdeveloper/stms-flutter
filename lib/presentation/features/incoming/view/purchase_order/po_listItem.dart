import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/incoming/po/po_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_po.dart';
import 'package:stms/data/local_db/incoming/po/po_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/po/po_scanItem_db.dart';
// import 'package:stms/data/local_db/master/master_inventory_db.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/card_text.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/skuUpc_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';
import 'package:stms/presentation/widgets/independent/view_dialog.dart';

class PoItemListView extends StatefulWidget {
  // final Function changeView;

  const PoItemListView({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _PoItemListViewState createState() => _PoItemListViewState();
}

class _PoItemListViewState extends State<PoItemListView> {
  var getPurchaseOrderItem = IncomingService();
  late Future<List<Map<String, dynamic>>> _future;
  DateTime date = DateTime.now();
  // bool _isDisable = true;
  List locList = [];
  List poItemList = [];
  List<InventoryHive> poSkuListing = [];
  List poItemListing = [];
  List poBarcodeListing = [];
  List allPoItem = [];
  List allPoNonItem = [];
  List receiptTypeList = [
    {"id": 1, "name": "Shipment"},
    {"id": 3, "name": "Shipment with invoice"},
  ];

  // ignore: unused_field
  String _scanBarcode = 'Unknown';
  var formatDate,
      selectedTxn = '0',
      selectedStatus,
      selectedItem,
      selectedVendorItem,
      selectedItemSequence,
      selectedReceipt,
      selectedLoc,
      itemPO,
      infoPO,
      getInfoPO,
      poDoc,
      poDate,
      poShipDate,
      supplier,
      poSerial,
      poNonTrack,
      combineUpdated,
      receiveQty,
      enterQty,
      itemName,
      locationId;
  // final _masterInventory = Hive.box<InventoryHive>('inventory');
  final format = DateFormat("yyyy-MM-dd");
  final TextEditingController vendorNoController = TextEditingController();
  final GlobalKey<StmsInputFieldState> vendorNoKey = GlobalKey();

  // call the function at start of page open
  @override
  void initState() {
    super.initState();
    scanData();
    formatDate = DateFormat('yyyy-MM-dd').format(date);
    getItemPo();
    getCommon();
    // call the enterQty whenever at start of this page
    getEnterQty();
    _future = getPurchaseOrderItem.getPurchaseOrderItem();

    fToast = FToast();
    fToast.init(context);
  }

  scanData() async {
    DBPoNonItem().getAllPoNonItem().then((value) => print(value));
  }

  // get po from API
  getItemPo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getPurchaseOrderItem.getPurchaseOrderItem().then((value) {
      setState(() {
        infoPO = prefs.getString('poId_info');
        getInfoPO = json.decode(infoPO);
        poItemList = value;

        poDoc = getInfoPO['po_doc'];
        poDate = getInfoPO['po_date'];
        poShipDate = getInfoPO['po_ship_date'];
        supplier = getInfoPO['supplier_name'];
      });
    });
  }

  // Get master location and master inventory file
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

    DBMasterInventoryHive().getAllInvHive().then((value) {
      if (value == null || value == []) {
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      }
    });
  }

  // check and get all the purchase order item and purchase order non item
  // POItem & PoNonItem
  getEnterQty() {
    DBPoItem().getAllPoItem().then((value) {
      // make the PoItem is equal to the item store in scanDB
      // It is the save info
      setState(() {
        allPoItem = value;
      });
    });

    DBPoNonItem().getAllPoNonItem().then((value) {
      setState(() {
        // Display and get all the PoNonItem after scanDB collected.
        // It is the save info
        allPoNonItem = value;
        print('SHOW ALL PO: $allPoNonItem');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Height and width of the screen size is set in this variable
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileProcessing) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return StmsScaffold(
            title: '',
            body: SingleChildScrollView(
              child: Container(
                height: height*0.9,
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The description view of the item
                    StmsCard(
                      title1: 'PO Doc No.',
                      subtitle1: '$poDoc',
                      title2: 'PO Date',
                      subtitle2: '$poDate',
                      title3: 'Shipment Date',
                      subtitle3: '$formatDate',
                      title4: 'Vendor Name',
                      subtitle4: '$supplier',
                    ),
                    // The table content
                    Expanded(
                      flex: 5,
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: [
                          Container(
                            // The header of the table
                            child: Table(
                              defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                              border: TableBorder.all(
                                  color: Colors.black, width: 1),
                              columnWidths: const <int, TableColumnWidth>{
                                0: FixedColumnWidth(70.0),
                                1: FixedColumnWidth(40.0),
                                2: FixedColumnWidth(40.0),
                                3: FixedColumnWidth(40.0),
                                4: FixedColumnWidth(40.0),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      height: 35,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'SKU',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          // height: 1.8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      'PO Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Received Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'ENT Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'BAL Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      ' ',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // The content of the table
                          Container(
                            child: FutureBuilder(
                              future: _future,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (snapshot
                                          .data[index]['item_receive_qty']
                                          ?.isEmpty ??
                                          true) {
                                        receiveQty = '0';
                                      } else {
                                        receiveQty = snapshot.data[index]
                                        ['item_receive_qty'];
                                      }

                                      var balQty = int.parse(snapshot
                                          .data[index]['item_quantity']) -
                                          int.parse(receiveQty);

                                      return Material(
                                        // color: index % 2 == 0 ? Colors.white : Colors.grey[400],
                                        child: Table(
                                          border: TableBorder.all(
                                            color: Colors.black,
                                            width: 0.2,
                                          ),
                                          defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                          columnWidths: const <int,
                                              TableColumnWidth>{
                                            0: FixedColumnWidth(70.0),
                                            1: FixedColumnWidth(40.0),
                                            2: FixedColumnWidth(40.0),
                                            3: FixedColumnWidth(40.0),
                                            4: FixedColumnWidth(40.0),
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                Container(
                                                  // height: 50,
                                                  padding: EdgeInsets.fromLTRB(
                                                      2, 0, 0, 0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "${snapshot.data[index]['item_name']}",
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      height: 2.3,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Text(
                                                  "${snapshot.data[index]['item_quantity']}",
                                                  style:
                                                  TextStyle(fontSize: 16.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  "$receiveQty",
                                                  style:
                                                  TextStyle(fontSize: 16.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                // Enter Quantity text
                                                // Will display whether it pass in the value or not
                                                // This s to check if Enter Quantity got value
                                                // using the master file snapshot check
                                                // THIS IS FOR ALLPOITEM
                                                snapshot.data[index]['tracking_type'] == "2" ? Text(
                                                  // to check if allPoItem got value or not
                                                  // If got value, check in the master file snapshot and compare the item_inventory_id
                                                  // Using the 'where' will go through the check process like a looping
                                                  allPoItem.isNotEmpty ? allPoItem.where((element)
                                                  => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']).isNotEmpty
                                                  // once check, if it is containing a value or the item_id in DB is same in the master file
                                                  // Get the length of the item_id
                                                      ? '${allPoItem.where((element) => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']).length}'
                                                  // If there is no match, then the result is display '0'
                                                      : '0'
                                                  // If the overall result is default as nothing, the display will also show '0'
                                                      : '0',
                                                  style: TextStyle(
                                                      fontSize: 16.0
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )
                                                    : Text(
                                                  // This one is to check if AllPoNonItem got value
                                                  // ALLPONONITEM section
                                                  // Need to check if there is a value after scan.
                                                  // Comparing both the DB and master file to check if there is a value before and after scan
                                                  allPoNonItem.isNotEmpty ? allPoNonItem.firstWhereOrNull((element) =>
                                                  element['item_inventory_id'] == snapshot.data[index]['item_inventory_id'] && element['line_seq_no'] == snapshot.data[index]['line_seq_no']) != null
                                                  // If got value, then display the tracking_qty
                                                      ? "${allPoNonItem.firstWhereOrNull((element) => element['item_inventory_id']
                                                      == snapshot.data[index]['item_inventory_id'] && element['line_seq_no'] == snapshot.data[index]['line_seq_no'])['non_tracking_qty']}"
                                                  // If no value after scan, which means it is not the same as in DB, then display '0'
                                                      : "0"
                                                  // This is generally display '0' if no value is found
                                                      : "0",
                                                  style: TextStyle(
                                                      fontSize: 16.0
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  "$balQty",
                                                  style:
                                                  TextStyle(fontSize: 16.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                // Button Area(Scan amd Manual)
                                                Column(
                                                  children: [
                                                    // SCAN BUTTON
                                                    snapshot.data[index][
                                                    'tracking_type'] ==
                                                        "2"
                                                        ? Container(
                                                      width: width,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.blueAccent,
                                                          minimumSize: Size(width * 0.015, height * 0.05),),
                                                        onPressed: balQty == 0 || balQty < 0 ? () {
                                                          ErrorDialog.showErrorDialog(context,
                                                              '${snapshot.data[index]['item_name']} is already received all qty.');}
                                                            : () async {
                                                          SharedPreferences prefs = await SharedPreferences.getInstance();

                                                          // save selected item_inventory id
                                                          selectedItem = snapshot.data[index]['item_inventory_id'];
                                                          prefs.setString('selectedIvID', selectedItem);

                                                          // Save selected vendor item no
                                                          selectedVendorItem = snapshot.data[index]['vendor_item_number'];
                                                          prefs.setString('vendorItemNo', selectedVendorItem);

                                                          // Save selected item sequence no
                                                          selectedItemSequence = snapshot.data[index]['line_seq_no'];
                                                          prefs.setString('line_seq_no', selectedItemSequence);

                                                          prefs.setString('poTracking', snapshot.data[index]['tracking_type']);
                                                          var tracking = snapshot.data[index]['tracking_type'];
                                                          var typeScan = 'scan';
                                                          itemName = snapshot.data[index]['item_name'];
                                                          checkReceiptType(tracking, typeScan);

                                                          // scanBarcodeNormal();
                                                        },
                                                        child: Text(
                                                          'SCAN',
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            16.0,
                                                            color: Colors
                                                                .white,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        : Container(
                                                      width: width,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.blueAccent,
                                                          minimumSize: Size(width * 0.015, height * 0.05),),
                                                        onPressed: balQty == 0 || balQty < 0 ? () {
                                                          ErrorDialog.showErrorDialog(
                                                              context, '${snapshot.data[index]['item_name']} is already received all qty.');
                                                        } : () async {
                                                          SharedPreferences prefs = await SharedPreferences.getInstance();

                                                          // save selected item_inventory id
                                                          selectedItem = snapshot.data[index]['item_inventory_id'];
                                                          prefs.setString('selectedIvID', selectedItem);

                                                          // Save selected vendor item no
                                                          selectedVendorItem = snapshot.data[index]['vendor_item_number'];
                                                          prefs.setString('vendorItemNo', selectedVendorItem);

                                                          // Save selected item sequence no
                                                          selectedItemSequence = snapshot.data[index]['line_seq_no'];
                                                          prefs.setString('line_seq_no', selectedItemSequence);

                                                          // save selected tracking no
                                                          prefs.setString('poTracking', snapshot.data[index]['tracking_type']);
                                                          var tracking = snapshot.data[index]['tracking_type'];
                                                          var typeScan = 'scan';
                                                          itemName = snapshot.data[index]['item_name'];
                                                          SkuUpcDialog.showSkuUpcDialog(context).then((value) {
                                                            checkReceiptType(tracking, typeScan);});
                                                          // scanBarcodeNormal();
                                                        },
                                                        child: Text(
                                                          'SCAN',
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            16.0,
                                                            color: Colors
                                                                .white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // MANUAL BUTTON
                                                    snapshot.data[index][
                                                    'tracking_type'] ==
                                                        "2"
                                                        ? Column(
                                                      children: [
                                                        // MANUAL BUTTON
                                                        Container(
                                                          width: width,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              primary: Colors
                                                                  .blueAccent,
                                                              minimumSize: Size(
                                                                  width *
                                                                      0.015,
                                                                  height *
                                                                      0.05),
                                                            ),
                                                            onPressed: balQty ==
                                                                0 ||
                                                                balQty <
                                                                    0
                                                                ? () {
                                                              ErrorDialog.showErrorDialog(
                                                                  context,
                                                                  '${snapshot.data[index]['item_name']} is already received all qty.');
                                                            }
                                                                : () async {
                                                              SharedPreferences
                                                              prefs =
                                                              await SharedPreferences.getInstance();

                                                              // save selected item_inventory id
                                                              selectedItem = snapshot.data[index]['item_inventory_id'];
                                                              prefs.setString('selectedIvID', selectedItem);

                                                              // Save selected vendor number
                                                              selectedVendorItem = snapshot.data[index]['vendor_item_number'];
                                                              prefs.setString('VendorItemNo', selectedVendorItem);



                                                              prefs.setString(
                                                                  'poTracking',
                                                                  snapshot.data[index]['tracking_type']);
                                                              var tracking =
                                                              snapshot.data[index]['tracking_type'];
                                                              var typeScan =
                                                                  'manual';
                                                              checkReceiptType(
                                                                  tracking,
                                                                  typeScan);
                                                            },
                                                            child: Text(
                                                              'MANUAL',
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                16.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // VIEW BUTTON
                                                        Container(
                                                          width: width,
                                                          child:
                                                          ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              primary: Colors
                                                                  .green,
                                                              minimumSize: Size(
                                                                  width *
                                                                      0.015,
                                                                  height *
                                                                      0.05),
                                                            ),
                                                            onPressed:
                                                                () {
                                                              viewBarcode(
                                                                  snapshot.data[index]
                                                                  [
                                                                  'item_inventory_id']);
                                                            },
                                                            child: Text(
                                                              'VIEW',
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                16.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                        : Container(
                                                      width: width,
                                                      child:
                                                      ElevatedButton(
                                                        style:
                                                        ElevatedButton
                                                            .styleFrom(
                                                          primary: Colors
                                                              .blueAccent,
                                                          minimumSize: Size(
                                                              width *
                                                                  0.015,
                                                              height *
                                                                  0.05),
                                                        ),
                                                        onPressed: balQty ==
                                                            0 ||
                                                            balQty < 0
                                                            ? () {
                                                          ErrorDialog.showErrorDialog(
                                                              context,
                                                              '${snapshot.data[index]['item_name']} is already received all qty.');
                                                        }
                                                            : () async {
                                                          SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          var typeScan =
                                                              'manual';

                                                          // save selected item_inventory id
                                                          selectedItem = snapshot.data[index]['item_inventory_id'];
                                                          // prefs.setString('selectedIvID', selectedItem);

                                                          // Save selected vendor item no
                                                          selectedVendorItem = snapshot.data[index]['vendor_item_number'];
                                                          prefs.setString('vendorItemNo', selectedVendorItem);
                                                          prefs.setString(
                                                              'poTracking',
                                                              snapshot.data[index]
                                                              [
                                                              'tracking_type']);
                                                          itemName =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];
                                                          SkuUpcDialog.showSkuUpcDialog(
                                                              context)
                                                              .then(
                                                                  (value) {
                                                                checkReceiptType(
                                                                    snapshot.data[index]['tracking_type'],
                                                                    typeScan);
                                                              });
                                                        },
                                                        child: Text(
                                                          'MANUAL',
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            16.0,
                                                            color: Colors
                                                                .white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Upload Button
                    Expanded(
                        flex: 1,
                        // Align to the bottom
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          // Custom button style
                          child: StmsStyleButton(
                            title: 'UPLOAD',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () {
                              uploadData();
                            },
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // pop up dialog box
  // Fill up credential before scan the item
  Future checkReceiptType(tracking, String typeScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var valueReceipt = prefs.getString('poReceiptType');
    print('receipt Type: $valueReceipt');

    if (valueReceipt == null) {
      return showDialog(
        context: context,
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;

          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: Container(
              height: height * 0.65,
              width: width,
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: height / 13,
                    child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return Container(
                          // padding: EdgeInsets.symmetric(horizontal: 5),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Receipt Type',
                              errorText:
                              state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: StatefulBuilder(
                              builder: (BuildContext context,
                                  StateSetter setState) {
                                return DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton<String>(
                                      isDense: true,
                                      iconSize: 28,
                                      iconEnabledColor: Colors.amber,
                                      items: receiptTypeList.map((item) {
                                        return new DropdownMenuItem(
                                          child: Text(
                                            item['name'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          value: item['id'].toString(),
                                        );
                                      }).toList(),
                                      isExpanded: false,
                                      value: selectedReceipt == ""
                                          ? ""
                                          : selectedReceipt,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedReceipt = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  StmsInputField(
                    key: vendorNoKey,
                    controller: vendorNoController,
                    hint: 'Vendor Doc No',
                    validator: Validator.valueExists,
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
                  // Select button
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: StmsStyleButton(
                        title: 'SELECT',
                        backgroundColor: Colors.amber,
                        textColor: Colors.black,
                        onPressed: () async {
                          if (selectedReceipt == null) {
                            ErrorDialog.showErrorDialog(
                                context, 'Please select receipt type');
                          } else if (vendorNoKey.currentState
                              ?.validate() !=
                              null) {
                            ErrorDialog.showErrorDialog(context,
                                'Vendor doc no. cannot be empty');
                          } else if (selectedLoc == null) {
                            ErrorDialog.showErrorDialog(
                                context, 'Please select Location');
                          } else {
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            prefs.setString(
                                'poReceiptType', selectedReceipt);
                            prefs.setString(
                                'povendorNo', vendorNoController.text);
                            prefs.setString('poLocation', locationId);

                            print('location: $locationId');
                            Navigator.pop(context);

                            if (tracking == "2" && typeScan == 'scan') {
                              scanBarcodeNormal();
                            } else if (tracking == "2" &&
                                typeScan == 'manual') {
                              Navigator.of(context)
                                  .pushNamed(StmsRoutes.poItemManual);
                            } else {
                              prefs.setString('nontypeScan', typeScan);
                              scanSKU();
                              // Navigator.of(context)
                              //     .pushNamed(StmsRoutes.poItemDetail);
                            }
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      if (tracking == "2" && typeScan == 'scan') {
        scanBarcodeNormal();
      } else if (tracking == "2" && typeScan == 'manual') {
        Navigator.of(context).pushNamed(StmsRoutes.poItemManual);
      } else {
        prefs.setString('nontypeScan', typeScan);
        scanSKU();
      }
    }
  }

  // scan code
  Future<void> scanSKU() async {
    String skuBarcode;
    var typeScanning = Storage().typeScan;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      skuBarcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);
      print('skuBarcode: $skuBarcode');
      if (skuBarcode != '-1') {
        if (typeScanning == 'sku') {
          searchSKU(skuBarcode);
        } else {
          searchUPC(skuBarcode);
        }
        // widget.changeView(changeType: ViewChangeType.Forward);
      } else {
        ErrorDialog.showErrorDialog(context, 'No barcode/qrcode detected');
      }
    } on PlatformException {
      skuBarcode = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = skuBarcode;
    });
  }

// search scan SKU code
  searchSKU(String skuBarcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBMasterInventoryHive().getAllInvHive().then((value) {
      poSkuListing = value;
      // print('sku master: $poSkuListing');

      var itemSku = poSkuListing.firstWhereOrNull(
              (element) => element.sku == skuBarcode && element.sku == itemName);

      // print('itemSku: $itemSku');
      // print('itemSku: ${itemSku!.sku}');

      // ignore: unnecessary_null_comparison
      if (null == itemSku) {
        ErrorDialog.showErrorDialog(
            context, 'SKU not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');
        print("selectedItem: $selectedItem");
        if (nonTrackingType == 'scan') {
          // Any update on the DB, need to call the value here as it will go and search through the model and db
          // Removing and addition will need to change here
          DBPoNonItem().getPoNonItem(selectedItem, selectedItemSequence).then((value) {
            if (value == null) {
              DBPoNonItem()
                  .createPoNonItem(PoNonItem(
                itemInvId: selectedItem,
                vendorItemName: selectedVendorItem,
                itemSequence: selectedItemSequence,
                nonTracking: '1',
              ))
                  .then((value) {
                // SuccessDialog.showSuccessDialog(context, 'Item Save');
                showCustomSuccess('Item Save');
                // call and update the enterQty function
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                      (element) => element['item_inventory_id'] == selectedItem
                          && element['line_seq_no'] == selectedItemSequence);
              print('HEEEEEEE: $selectedItemSequence');
              // print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty'])+1;
              DBPoNonItem()
                  .update(selectedItem, newQty.toString())
                  .then((value) {
                showCustomSuccess('Item Save');
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          Navigator.of(context).pushNamed(StmsRoutes.poItemDetail)
              .then((value){
            var _duration = Duration(seconds: 1);
            return Timer(_duration, getEnterQty);
          });
        }
      }
    });
  }

  // search scanUPC code
  searchUPC(String skuBarcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBMasterInventoryHive().getAllInvHive().then((value) {
      poSkuListing = value;

      var itemUpc = poSkuListing.firstWhereOrNull(
              (element) => element.upc == skuBarcode && element.sku == itemName);

      if (null == itemUpc) {
        ErrorDialog.showErrorDialog(
            context, 'UPC not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');
        print("selecteditem :$selectedItem");
        if (nonTrackingType == 'scan') {
          // Any update on the DB, need to call the value here as it will go and search through the model and db
          // Removing and addition will need to change here
          DBPoNonItem().getPoNonItem(selectedItem, selectedItemSequence).then((value) {
            if (value == null) {
              DBPoNonItem()
                  .createPoNonItem(PoNonItem(
                itemInvId: selectedItem,
                itemSequence: selectedItemSequence,
                vendorItemName: selectedVendorItem,
                nonTracking: '1',
              ))
                  .then((value) {
                // SuccessDialog.showSuccessDialog(context, 'Item Save');
                showCustomSuccess('Item Save');
                // call and update the enterQty function
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                      (element) => element['item_inventory_id'] == selectedItem);

              // print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty']) + 1;
              DBPoNonItem()
                  .update(selectedItem, newQty.toString())
                  .then((value) {
                getEnterQty();
                showCustomSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          Navigator.of(context).pushNamed(StmsRoutes.poItemDetail)
              .then((value) {
            var _duration = Duration(seconds: 1);
            return Timer(_duration, getEnterQty);
          });
        }
      }
    });
  }

  // Scan for trackingType == '2'. Item that got serial no
  Future<void> scanBarcodeNormal() async {

    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);
      print('barcodeScanRes: $barcodeScanRes');
      if (barcodeScanRes != '-1') {
        print('barcode: $barcodeScanRes');
        saveData(barcodeScanRes);
        // widget.changeView(changeType: ViewChangeType.Forward);
      } else {
        ErrorDialog.showErrorDialog(context, 'No barcode/qrcode detected');
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> saveData(String barcodeScanRes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBPoItem().getAllPoItem().then((value) {
      if (value != null) {
        poItemListing = value;

        var itemPO = poItemListing.firstWhereOrNull(
                (element) => element['item_serial_no'] == barcodeScanRes);
        if (null == itemPO) {
          prefs.setString("itemBarcode", barcodeScanRes);

          Navigator.of(context)
              .pushNamed(StmsRoutes.poItemDetail)
              .then((value) {
            // sent update Ent qty result
            getEnterQty();
            var _duration = Duration(seconds: 1);
            return Timer(_duration, scanBarcodeNormal);
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
        }
      } else {
        prefs.setString("itemBarcode", barcodeScanRes);

        // await Future.delayed(const Duration(seconds: 3));
        Navigator.of(context).pushNamed(StmsRoutes.poItemDetail).then((value) {
          // sent update Ent qty result
          getEnterQty();
          var _duration = Duration(seconds: 1);
          return Timer(_duration, scanBarcodeNormal);
        });
      }
    });
  }

  viewBarcode(String invNo) async {
    DBPoItem().getBarcodePoItem(invNo).then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(context, 'No Serial No have been scan');
      } else {
        var getList = DBPoItem().getBarcodePoItem(invNo);
        var getDb = 'DBPoItem';
        ViewDialog.showViewDialog(context, getList, getDb);
      }
    });
  }

  Future<void> uploadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('poId: ${prefs.getString('poId_upload')}');
    var receiptType = prefs.getString('poReceiptType');

    DBPoItem().getUpload().then((value) {
      // print('value serial po: $value');
      poSerial = value;
    });

    DBPoNonItem().getUpload().then((value) {
      print('value non Po: $value');
      poNonTrack = value;
      if (poSerial != null && poNonTrack != null) {
        combineUpdated = []
          ..addAll(poSerial)
          ..addAll(poNonTrack);
      } else if (poSerial == null) {
        combineUpdated = poNonTrack;
      } else {
        combineUpdated = poSerial;
      }

      IncomingService().sendToServer(combineUpdated).then((value) {
        if (value['status'] == true) {
          DBPoItem().deleteAllPoItem();
          DBPoNonItem().deleteAllPoNonItem();
          // prefs.remove('poReceiptType');
          prefs.remove('povendorNo');
          prefs.remove('poLocation');
          prefs.remove('poId_info');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.purchaseOrder));
          if (receiptType == '1') {
            SuccessDialog.showSuccessDialog(
                context, "Shipment created successfully")
                .then((value) {
              prefs.remove('poReceiptType');
            }); //value['message']
          } else {
            SuccessDialog.showSuccessDialog(
                context, "Shipment Invoice created successfully")
                .then((value) {
              prefs.remove('poReceiptType');
            });
          }
        } else {
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });
  }

  delete() {
    DBPoItem().deleteAllPoItem();
  }
}
