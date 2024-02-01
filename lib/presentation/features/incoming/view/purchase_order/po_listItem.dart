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
import 'package:stms/presentation/widgets/independent/view_dialog.dart';

class PoItemListView extends StatefulWidget {
  // final Function changeView;

  const PoItemListView({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _PoItemListViewState createState() => _PoItemListViewState();
}

// Detail page, display the item of the selected document from previous page
class _PoItemListViewState extends State<PoItemListView> {
  // Initialize variable
  var getPurchaseOrderItem = IncomingService();
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
      allPoEmpty,
      allPoNonEmpty,
      combineUpdated,
      receiveQty,
      enterQty,
      itemName,
      locationId;

  late Future<List<Map<String, dynamic>>> _future; // variable get from domain

  // Initialize variable for date and time
  DateTime date = DateTime.now();

  // Initialize list
  List locList = [];
  List poItemList = [];
  List<InventoryHive> poSkuListing = [];
  List poItemListing = [];
  List poBarcodeListing = [];
  List allPoItem = [];
  List allPoNonItem = [];
  List allPOFromAPI = [];
  List receiptTypeList = [
    {"id": 1, "name": "Shipment"},
    {"id": 3, "name": "Shipment with invoice"},
  ];
  // For search sku
  List searchItem = [];
  TextEditingController toSearch = TextEditingController();

  String _scanBarcode = 'Unknown';

  // final _masterInventory = Hive.box<InventoryHive>('inventory');
  final format = DateFormat("yyyy-MM-dd");
  final TextEditingController vendorNoController =
  TextEditingController(); // variable for Text Editing
  final GlobalKey<StmsInputFieldState> vendorNoKey =
  GlobalKey(); // key use in Text Editing

  // Initialize function
  @override
  void initState() {
    super.initState();
    // scanData();
    formatDate =
        DateFormat('yyyy-MM-dd').format(date); // Get date on page refresh
    getItemPo(); // Call getItemPo function on page refresh
    getCommon(); // Call getCommon function on page refresh
    getEnterQty(); // Call getEnterQty function on page refresh
    _future = getPurchaseOrderItem
        .getPurchaseOrderItem(); // Store API data of PO in _future variable

    // Call custom toast class
    fToast = FToast();
    fToast.init(context);

    print('TEST: $allPoNonItem');
  }

  // scanData() async {
  //   DBPoNonItem().getAllPoNonItem().then((value) => print(value));
  // }

  // Function for calling data from API
  getItemPo() async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getPurchaseOrderItem.getPurchaseOrderItem().then((value) {
      setState(() {
        allPOFromAPI = value;
        print('ALL PO: $allPOFromAPI');
        searchItem = List.from(allPOFromAPI);
        // Get data from API and store into selected variable
        infoPO = prefs.getString('poId_info');
        getInfoPO = json.decode(infoPO);
        poItemList = value; // Store API value into poItemList variable

        poDoc = getInfoPO['po_doc']; // Get po_doc from API into poDoc variable
        poDate =
        getInfoPO['po_date']; // Get po_date from API into poDate variable
        poShipDate = getInfoPO[
        'po_ship_date']; // Get po_ship_date API into poShipDate variable
        supplier = getInfoPO[
        'supplier_name']; // Get supplier_name API into supplier variable
      });
    });
  }

  // Function for calling data from Master Page
  getCommon() {
    // Master Page
    DBMasterLocation().getAllMasterLoc().then((value) {
      // Check if got data from Master
      if (value == null) {
        // If no data
        ErrorDialog.showErrorDialog(
            context, 'Please download location file at master page first');
      } else {
        // If have data
        setState(() {
          locList = value; // Store data in locList variable
        });
      }
    });

    // API
    DBMasterInventoryHive().getAllInvHive().then((value) {
      // Check if got data in API / Master page
      if (value == null || value == []) {
        // If no data
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      }
    });
  }

  // Function for calling enter quantity data from Database
  getEnterQty() {
    // For PoItem
    DBPoItem().getAllPoItem().then((value) {
      // Check if got value or not
      if (value != null) {
        // If got value
        setState(() {
          allPoItem = value; // Store DB value into allPoItem variable
          allPoEmpty = allPoItem
              .length; // Get the total item present (base on how many) and store in allPoEmpty
        });
        // If no value
      } else {
        allPoEmpty = '0'; // Set the allPoEmpty variable to 0

        // Call Po Item from API to get back the value
        getPurchaseOrderItem.getPurchaseOrderItem();
      }
    });

    // For PoNonItem
    DBPoNonItem().getAllPoNonItem().then((value) {
      // Check if got value or not
      print('VALUE TEST: $value');
      if (value != null) {
        // If got value
        setState(() {
          allPoNonItem = value; // Store DB value into allPoNonItem variable
          allPoNonEmpty = allPoNonItem
              .length; // Get the total item present (base on how many) and store in allPoNonEmpty
        });
        // If no value
      } else {
        allPoNonEmpty = '0'; // Set the allPoNonEmpty variable to 0

        // Call Po Item from API to get back the value
        getPurchaseOrderItem.getPurchaseOrderItem();
      }
    });
  }

  // UI layout
  @override
  Widget build(BuildContext context) {
    // Height and width of the screen size is set in this variable
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // Safe Area for matching phone screen size
    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileProcessing) {
            // Loading circle
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              )
            );
          }
          // The whole layout
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
                    // Search function
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextField(
                        onChanged: (value){
                          setState(() {
                            searchItem = allPOFromAPI.where((string) => string['item_name'].toLowerCase().contains(value.toLowerCase())).toList();
                          });
                        },
                        controller: toSearch,
                        decoration: const InputDecoration(
                            hintText: 'Search SKU...',
                            labelText: 'Search SKU...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                            )
                        ),
                      ),
                    ),
                    // The table content
                    Expanded(
                      flex: 5,
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: [
                          // Table header title
                          Container(
                            child: Table(
                              defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                              border: TableBorder.all(
                                  color: Colors.black, width: 1),
                              // Set fixed table column width
                              columnWidths: const <int, TableColumnWidth>{
                                0: FixedColumnWidth(70.0),
                                1: FixedColumnWidth(40.0),
                                2: FixedColumnWidth(40.0),
                                3: FixedColumnWidth(40.0),
                                4: FixedColumnWidth(40.0),
                              },
                              children: [
                                // Table title design
                                TableRow(
                                  children: [
                                    Container(
                                      height: 35,
                                      alignment: Alignment.center,
                                      // Title text for SKU / Serial Number
                                      child: Text(
                                        'SKU',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          // height: 1.8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    // Title text for Production Quantity
                                    Text(
                                      'PO Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Title text for Received Quantity
                                    Text(
                                      'Received Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Title text for Entered Quantity
                                    Text(
                                      'ENT Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Title text for Balance Quantity
                                    Text(
                                      'BAL Qty',
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Empty spot
                                    Container(
                                      height: 35,
                                      child: Text(''),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Table content
                          Container(
                            child: FutureBuilder(
                              // Call _future variable
                              future: _future,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                  // Loading layout
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                  // Table content layout
                                } else {
                                  // return toSearch.text.isEmpty
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    itemCount: toSearch.text.isEmpty
                                        ? snapshot.data.length
                                        : searchItem.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      // Check if got data in received quantity

                                      if (toSearch.text.isEmpty
                                          ? snapshot.data[index]
                                      ['item_receive_qty'] ==
                                          null
                                          : searchItem[index]
                                      ['item_receive_qty']
                                          .toString()
                                          .isEmpty) {
                                        // If no data
                                        receiveQty = '0';
                                      } else {
                                        // If got data
                                        receiveQty = toSearch.text.isEmpty
                                            ? snapshot.data[index]
                                        ['item_receive_qty']
                                            : searchItem[index]
                                        ['item_receive_qty'];
                                      }

                                      // // Method to get enter quantity
                                      // // Check if Serial Number or not
                                      // if(snapshot.data[index]['tracking_type'] == '2'){
                                      //   // If Serial Number
                                      //
                                      //   // Compare value based on ID and line sequence
                                      //   var entering = allPoItem.where((element) =>
                                      //   element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']
                                      //       && element['line_seq_no'] == snapshot.data[index]['line_seq_no']);
                                      //
                                      //   // Check if entering got value and allPoEmpty variable is not 0
                                      //   if(allPoEmpty != '0'){
                                      //     // If got value and allPoEmpty not 0
                                      //     enterQty = entering.length.toString();
                                      //   } else {
                                      //     // If no value
                                      //     enterQty = '0';
                                      //   }
                                      // } else {
                                      //   // If not Serial Number
                                      //
                                      //   // Compare value based on ID and line sequence
                                      //   var entering = allPoNonItem.firstWhereOrNull((element) =>
                                      //   element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']
                                      //       && element['line_seq_no'] == snapshot.data[index]['line_seq_no']);
                                      //
                                      //   // Check if entering got value and allPoNonEmpty variable is not 0
                                      //   if(entering != null && allPoNonEmpty != '0'){
                                      //     // If got value and allPoNonEmpty not 0
                                      //     enterQty = entering['non_tracking_qty'];
                                      //     print('ENT2: $entering');
                                      //   } else {
                                      //     // If no value
                                      //     enterQty = '0';
                                      //   }
                                      // }

                                      // Method to get balance quantity
                                      // var balQty = int.parse(snapshot.data[index]['item_quantity']) - int.parse(enterQty);

                                      var balQty = int.parse(snapshot
                                          .data[index]['item_quantity']) -
                                          int.parse(receiveQty);

                                      // Table content
                                      return Material(
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
                                            // Content Description
                                            TableRow(
                                              children: [
                                                // SKU / Serial Number Name
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      2, 0, 0, 0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    toSearch.text.isEmpty
                                                        ? "${snapshot.data[index]['item_name']}"
                                                        : "${searchItem[index]['item_name']}",
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      height: 2.3,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                // Item quantity value
                                                Text(
                                                  toSearch.text.isEmpty
                                                      ? "${snapshot.data[index]['item_quantity']}"
                                                      : "${searchItem[index]['item_quantity']}",
                                                  style:
                                                  TextStyle(fontSize: 16.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                // Receive quantity value
                                                Text(
                                                  "$receiveQty",
                                                  style:
                                                  TextStyle(fontSize: 16.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                // Enter quantity value
                                                Container(
                                                  height: height * 0.11,
                                                  child: Stack(
                                                    children: [
                                                      // Enter Quantity text
                                                      // Center(
                                                      //   child: Text(
                                                      //     "$enterQty",
                                                      //     style: TextStyle(
                                                      //         fontSize: 16.0),
                                                      //     textAlign: TextAlign.center,
                                                      //   ),
                                                      // ),

                                                      Center(
                                                        child:
                                                        // For AllPoItem
                                                        // Check if item under Serial or Non Serial
                                                        toSearch.text
                                                            .isEmpty
                                                            ? snapshot.data[index]
                                                        [
                                                        'tracking_type'] ==
                                                            "2"
                                                            ? Text(
                                                          // Check if got value and also if value not 0
                                                          allPoItem.isNotEmpty &&
                                                              allPoEmpty != '0'
                                                              ?
                                                          // Compare value based on ID and line sequence
                                                          allPoItem.where((element) => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id'] && element['line_seq_no'] == snapshot.data[index]['line_seq_no']).isNotEmpty

                                                          // If got value
                                                              ? '${allPoItem.where((element) => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id'] && element['line_seq_no'] == snapshot.data[index]['line_seq_no']).length}'

                                                          // If there is no match, then the result is display '0'
                                                              : '0'

                                                          // If the overall result is default as nothing, the display will also show '0'
                                                              : '0',
                                                          style: TextStyle(
                                                              fontSize:
                                                              16.0),
                                                          textAlign:
                                                          TextAlign.center,
                                                        )

                                                        // For AllPoNonItem
                                                        // Check if got value and also if value is 0
                                                            : Text(
                                                          allPoNonItem.isNotEmpty &&
                                                              allPoNonEmpty != '0'
                                                              ?
                                                          // Compare value based on ID and line sequence
                                                          allPoNonItem.firstWhereOrNull((element) => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id'] && element['line_seq_no'] == snapshot.data[index]['line_seq_no']) != null
                                                          // If got value
                                                              ? "${allPoNonItem.firstWhereOrNull((element) => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id'] && element['line_seq_no'] == snapshot.data[index]['line_seq_no'])['non_tracking_qty']}"

                                                          // If there is no match, then the result is display '0'
                                                              : '0'

                                                          // If the overall result is default as nothing, the display will also show '0'
                                                              : '0',
                                                          style: TextStyle(
                                                              fontSize:
                                                              16.0),
                                                          textAlign:
                                                          TextAlign.center,
                                                        )
                                                            : searchItem[index]
                                                        [
                                                        'tracking_type'] ==
                                                            "2"
                                                            ? Text(
                                                          // Check if got value and also if value not 0
                                                          allPoItem.isNotEmpty &&
                                                              allPoEmpty != '0'
                                                              ?
                                                          // Compare value based on ID and line sequence
                                                          allPoItem.where((element) => element['item_inventory_id'] == searchItem[index]['item_inventory_id'] && element['line_seq_no'] == searchItem[index]['line_seq_no']).isNotEmpty

                                                          // If got value
                                                              ? '${allPoItem.where((element) => element['item_inventory_id'] == searchItem[index]['item_inventory_id'] && element['line_seq_no'] == searchItem[index]['line_seq_no']).length}'

                                                          // If there is no match, then the result is display '0'
                                                              : '0'

                                                          // If the overall result is default as nothing, the display will also show '0'
                                                              : '0',
                                                          style: TextStyle(
                                                              fontSize:
                                                              16.0),
                                                          textAlign:
                                                          TextAlign.center,
                                                        )

                                                        // For AllPoNonItem
                                                        // Check if got value and also if value is 0
                                                            : Text(
                                                          allPoNonItem.isNotEmpty &&
                                                              allPoNonEmpty != '0'
                                                              ?
                                                          // Compare value based on ID and line sequence
                                                          allPoNonItem.firstWhereOrNull((element) => element['item_inventory_id'] == searchItem[index]['item_inventory_id'] && element['line_seq_no'] == searchItem[index]['line_seq_no']) != null
                                                          // If got value
                                                              ? "${allPoNonItem.firstWhereOrNull((element) => element['item_inventory_id'] == searchItem[index]['item_inventory_id'] && element['line_seq_no'] == searchItem[index]['line_seq_no'])['non_tracking_qty']}"

                                                          // If there is no match, then the result is display '0'
                                                              : '0'

                                                          // If the overall result is default as nothing, the display will also show '0'
                                                              : '0',
                                                          style: TextStyle(
                                                              fontSize:
                                                              16.0),
                                                          textAlign:
                                                          TextAlign.center,
                                                        ),
                                                      ),

                                                      // Reset Icon
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            // Empty space
                                                            SizedBox(
                                                              height:
                                                              height * 0.07,
                                                            ),
                                                            // Reset Icon position
                                                            Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: IconButton(
                                                                icon: Icon(
                                                                  Icons.update,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20,
                                                                ),
                                                                onPressed: () {
                                                                  // check if SN or not
                                                                  if (snapshot.data[
                                                                  index]
                                                                  [
                                                                  'tracking_type'] ==
                                                                      "2") {
                                                                    // If Serial Number
                                                                    setState(
                                                                            () {
                                                                          // Call delete PoNonItem function
                                                                          // Delete Id and line sequence
                                                                          deletePoItem(
                                                                            snapshot.data[index]
                                                                            [
                                                                            'item_inventory_id'],
                                                                            snapshot.data[index]
                                                                            [
                                                                            'line_seq_no'],
                                                                          );
                                                                          // Call getEnterQty function
                                                                          getEnterQty();
                                                                        });
                                                                  } else {
                                                                    // If not Serial Number
                                                                    setState(
                                                                            () {
                                                                          // Call delete PoNonItem function
                                                                          // Delete Id and line sequence
                                                                          deletePoNonItem(
                                                                            snapshot.data[index]
                                                                            [
                                                                            'item_inventory_id'],
                                                                            snapshot.data[index]
                                                                            [
                                                                            'line_seq_no'],
                                                                          );
                                                                          // Call getEnterQty function
                                                                          getEnterQty();
                                                                        });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Balance quantity value
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
                                                    // Check if Serial Number or not
                                                    snapshot.data[index][
                                                    'tracking_type'] ==
                                                        "2"
                                                        ? Container(
                                                      width: width,
                                                      // If Serial Number
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

                                                        // Check if balance got value
                                                        onPressed: balQty ==
                                                            0 ||
                                                            balQty < 0
                                                            ? () {
                                                          // If no value
                                                          ErrorDialog.showErrorDialog(
                                                              context,
                                                              '${snapshot.data[index]['item_name']} is already received all qty.');
                                                        }
                                                            : () async {
                                                          // If got value
                                                          // SharedPreferences use to get and save selected data
                                                          SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();

                                                          // save selected item_inventory id
                                                          selectedItem =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];
                                                          // prefs.setString('selectedIvID', selectedItem);
                                                          Storage()
                                                              .selectedInvId =
                                                              selectedItem;

                                                          // Save selected vendor item no
                                                          selectedVendorItem =
                                                          snapshot.data[index]
                                                          [
                                                          'vendor_item_number'];
                                                          prefs.setString(
                                                              'vendorItemNo',
                                                              selectedVendorItem);

                                                          // Save selected item sequence no
                                                          selectedItemSequence =
                                                          snapshot.data[index]
                                                          [
                                                          'line_seq_no'];
                                                          // prefs.setString('line_seq_no', selectedItemSequence);
                                                          Storage()
                                                              .lineSeqNo =
                                                              selectedItemSequence;

                                                          // Save selected tracking no
                                                          prefs.setString(
                                                              'poTracking',
                                                              snapshot.data[index]
                                                              [
                                                              'tracking_type']);

                                                          // Set variable tracking and typeScan as tracking type
                                                          var tracking =
                                                          snapshot.data[index]
                                                          [
                                                          'tracking_type'];
                                                          var typeScan =
                                                              'scan';

                                                          // Store item name into itemName variable
                                                          itemName =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];

                                                          // Call checkReceiptType function as pop up dialog
                                                          checkReceiptType(
                                                              tracking,
                                                              typeScan);
                                                        },
                                                        // SCAN Button Text
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
                                                      // If Non Serial
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

                                                        // Check if balance got value
                                                        onPressed: balQty ==
                                                            0 ||
                                                            balQty < 0
                                                            ? () {
                                                          // If no value
                                                          ErrorDialog.showErrorDialog(
                                                              context,
                                                              '${snapshot.data[index]['item_name']} is already received all qty.');
                                                        }
                                                            : () async {
                                                          // If got value
                                                          // SharedPreferences use to get and save selected data
                                                          SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();

                                                          // Save selected item_inventory id
                                                          selectedItem =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];
                                                          // prefs.setString('selectedIvID', selectedItem);
                                                          Storage()
                                                              .selectedInvId =
                                                              selectedItem;

                                                          // Save selected vendor item no
                                                          selectedVendorItem =
                                                          snapshot.data[index]
                                                          [
                                                          'vendor_item_number'];
                                                          prefs.setString(
                                                              'vendorItemNo',
                                                              selectedVendorItem);

                                                          // Save selected item sequence no
                                                          selectedItemSequence =
                                                          snapshot.data[index]
                                                          [
                                                          'line_seq_no'];
                                                          // prefs.setString('line_seq_no', selectedItemSequence);
                                                          Storage()
                                                              .lineSeqNo =
                                                              selectedItemSequence;

                                                          // Save selected tracking no
                                                          prefs.setString(
                                                              'poTracking',
                                                              snapshot.data[index]
                                                              [
                                                              'tracking_type']);

                                                          // Set variable tracking and typeScan as tracking type
                                                          var tracking =
                                                          snapshot.data[index]
                                                          [
                                                          'tracking_type'];
                                                          var typeScan =
                                                              'scan';

                                                          // Store item name into itemName variable
                                                          itemName =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];

                                                          // Call checkReceiptType function as pop up dialog
                                                          SkuUpcDialog.showSkuUpcDialog(
                                                              context)
                                                              .then(
                                                                  (value) {
                                                                checkReceiptType(
                                                                    tracking,
                                                                    typeScan);
                                                              });
                                                        },
                                                        // SCAN Button Text
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
                                                    // Check if Serial Number or not
                                                    snapshot.data[index][
                                                    'tracking_type'] ==
                                                        "2"
                                                        ? Column(
                                                      children: [
                                                        Container(
                                                          width: width,
                                                          // If Serial Number
                                                          child:
                                                          ElevatedButton(
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
                                                            // Check if balance got value
                                                            onPressed: balQty ==
                                                                0 ||
                                                                balQty <
                                                                    0
                                                                ? () {
                                                              // If no value
                                                              ErrorDialog.showErrorDialog(
                                                                  context,
                                                                  '${snapshot.data[index]['item_name']} is already received all qty.');
                                                            }
                                                                : () async {
                                                              // If got value
                                                              // SharedPreferences use to get and save selected data
                                                              SharedPreferences
                                                              prefs =
                                                              await SharedPreferences.getInstance();

                                                              // Save selected item_inventory id
                                                              selectedItem =
                                                              snapshot.data[index]['item_name'];
                                                              // prefs.setString('selectedIvID', selectedItem);
                                                              Storage().selectedInvId =
                                                                  selectedItem;

                                                              // Save selected vendor number
                                                              selectedVendorItem =
                                                              snapshot.data[index]['vendor_item_number'];
                                                              prefs.setString(
                                                                  'VendorItemNo',
                                                                  selectedVendorItem);

                                                              // Save selected item sequence no
                                                              selectedItemSequence =
                                                              snapshot.data[index]['line_seq_no'];
                                                              // prefs.setString('line_seq_no', selectedItemSequence);
                                                              Storage().lineSeqNo =
                                                                  selectedItemSequence;

                                                              // Set variable tracking and typeScan as tracking type
                                                              prefs.setString(
                                                                  'poTracking',
                                                                  snapshot.data[index]['tracking_type']);
                                                              var tracking =
                                                              snapshot.data[index]['tracking_type'];
                                                              var typeScan =
                                                                  'manual';

                                                              // Call checkReceiptType function as pop up dialog
                                                              checkReceiptType(
                                                                  tracking,
                                                                  typeScan);
                                                            },
                                                            // MANUAL Button Text
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
                                                            // Call viewBarcode function
                                                            // Call ID and line sequence
                                                            onPressed:
                                                                () {
                                                              viewBarcode(
                                                                  snapshot.data[index]
                                                                  [
                                                                  'item_inventory_id'],
                                                                  snapshot.data[index]
                                                                  [
                                                                  'line_seq_no']);
                                                            },
                                                            // VIEW button text
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
                                                      // If Non Serial Number
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
                                                        // Check if balance got value
                                                        onPressed: balQty ==
                                                            0 ||
                                                            balQty < 0
                                                            ? () {
                                                          // If no value
                                                          ErrorDialog.showErrorDialog(
                                                              context,
                                                              '${snapshot.data[index]['item_name']} is already received all qty.');
                                                        }
                                                            : () async {
                                                          // If got value
                                                          // SharedPreferences use to get and save selected data
                                                          SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          var typeScan =
                                                              'manual';

                                                          // save selected item_inventory id
                                                          selectedItem =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];
                                                          // prefs.setString('selectedIvID', selectedItem);
                                                          Storage()
                                                              .selectedInvId =
                                                              selectedItem;

                                                          // Save selected vendor item no
                                                          selectedVendorItem =
                                                          snapshot.data[index]
                                                          [
                                                          'vendor_item_number'];
                                                          prefs.setString(
                                                              'vendorItemNo',
                                                              selectedVendorItem);

                                                          // Save selected item sequence no
                                                          selectedItemSequence =
                                                          snapshot.data[index]
                                                          [
                                                          'line_seq_no'];
                                                          // prefs.setString('line_seq_no', selectedItemSequence);
                                                          Storage()
                                                              .lineSeqNo =
                                                              selectedItemSequence;

                                                          // Set variable tracking and typeScan as tracking type
                                                          prefs.setString(
                                                              'poTracking',
                                                              snapshot.data[index]
                                                              [
                                                              'tracking_type']);

                                                          // Store item name into itemName variable
                                                          itemName =
                                                          snapshot.data[index]
                                                          [
                                                          'item_name'];

                                                          // Call checkReceiptType function as pop up dialog
                                                          SkuUpcDialog.showSkuUpcDialog(
                                                              context)
                                                              .then(
                                                                  (value) {
                                                                checkReceiptType(
                                                                    snapshot.data[index]['tracking_type'],
                                                                    typeScan);
                                                              });
                                                        },
                                                        // MANUAL Button Text
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

  // Function for pop up dialog
  Future checkReceiptType(tracking, String typeScan) async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var valueReceipt = prefs.getString('poReceiptType');                         // Get poReceiptType from onPressed Scan / Manual button
    print('receipt Type: $valueReceipt');

    // Check if got value or not
    if (valueReceipt == null) {
      // If no value, create a form in a pop-up dialog format
      return showDialog(
        context: context,
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;

          // Dialog widget
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
                  // Receipt type
                  Container(
                    height: height / 13,
                    child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        // Receipt type title text
                        return Container(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Receipt Type',
                              errorText:
                              state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            // Drop down menu
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
                                        // Item name list from drop down
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
                                          // Drop down content change base on content selected
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
                  // Doc number text
                  StmsInputField(
                    key: vendorNoKey,
                    controller: vendorNoController,
                    hint: 'Vendor Doc No',
                    validator: Validator.valueExists,
                  ),
                  // Item location drop down
                  FormField<String>(
                    builder: (FormFieldState<String> state) {
                      // Item location title text
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
                          iconDisabledColor: Colors.grey[350],
                          items: locList.map((item) {
                            // Item name list from drop down
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
                              // Drop down content change base on content selected
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
                          // Check if form is filled or not
                          if (selectedReceipt == null) {
                            // If receipt type is empty
                            ErrorDialog.showErrorDialog(
                                context, 'Please select receipt type');
                          } else if (vendorNoKey.currentState
                              ?.validate() != null) {
                            // If vendor doc is empty
                            ErrorDialog.showErrorDialog(context,
                                'Vendor doc no. cannot be empty');
                          } else if (selectedLoc == null) {
                            // If location is empty
                            ErrorDialog.showErrorDialog(
                                context, 'Please select Location');
                          } else {
                            // If not empty

                            // SharedPreferences use to get and save selected data
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString('poReceiptType', selectedReceipt);
                            prefs.setString('povendorNo', vendorNoController.text);
                            prefs.setString('poLocation', locationId);

                            print('location: $locationId');
                            Navigator.pop(context);

                            // Check if serial and if type of scan
                            if (tracking == "2" && typeScan == 'scan') {
                              // If serial number and type is 'scan'

                              // Call scan Barcode function
                              scanBarcodeNormal();
                            } else if (tracking == "2" && typeScan == 'manual') {
                              // If serial number and type is 'manual'

                              // Navigate to itemManual page
                              Navigator.of(context).pushNamed(StmsRoutes.poItemManual).then((value){
                                // Call getEnterQt
                                getEnterQty();
                              });
                            } else {
                              // Store scan type
                              prefs.setString('nontypeScan', typeScan);
                              // Call scanSku function
                              scanSKU();
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
      // If got value
      // check if serial number is what type
      if (tracking == "2" && typeScan == 'scan') {
        // If serial number is type scan

        // Call scanBarcodeNormal function
        scanBarcodeNormal();
      } else if (tracking == "2" && typeScan == 'manual') {
        // If serial number is type scan manual

        // Navigate to create item Manual page
        Navigator.of(context).pushNamed(StmsRoutes.poItemManual).then((value){
          getEnterQty();                                                         // Call enter quantity function
        });
      } else {
        // If not serial number

        // Store data of type scan
        prefs.setString('nontypeScan', typeScan);
        scanSKU();                                                               // Call scanSKU function
      }
    }
  }

  // Function for scan if select SKU and UPC
  Future<void> scanSKU() async {
    String skuBarcode;
    var typeScanning = Storage().typeScan;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      skuBarcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);
      print('skuBarcode: $skuBarcode');

      // Check which scan type
      if (skuBarcode != '-1') {
        if (typeScanning == 'sku') {
          // If select SKU
          searchSKU(skuBarcode);
        } else {
          // If select UPC
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

  // Function for search SKU after scan SKU
  searchSKU(String skuBarcode) async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBMasterInventoryHive().getAllInvHive().then((value) {
      poSkuListing = value;                                                      // Get value from API into poSkuListing variable

      print('ITEM NAME2: $itemName');
      // Compare similar item name / sku
      var itemSku = poSkuListing.firstWhereOrNull(
              (element) => element.sku == skuBarcode && element.sku == itemName);

      // ignore: unnecessary_null_comparison
      // Check if got value or not
      if (null == itemSku) {
        // If no value
        ErrorDialog.showErrorDialog(
            context, 'SKU not match with master inventory');
      } else {
        // If fot value
        var nonTrackingType = prefs.getString('nontypeScan');
       // prefs.setString('selectedIvID', selectedItem);
        Storage().selectedInvId = selectedItem;

        print("selectedItem: $selectedItem");

        // Check the type of scan
        if (nonTrackingType == 'scan') {
          // If type is 'scan'
          // Get data from DB
          DBPoNonItem().getPoNonItem(itemSku.id, selectedItemSequence).then((value) {
            // Check if got value in DB
            if (value == null) {
              // If no value

              // Create new data
              DBPoNonItem()
                  .createPoNonItem(PoNonItem(
                itemInvId: itemSku.id,
                vendorItemName: selectedVendorItem,
                itemSequence: selectedItemSequence,
                nonTracking: '1',
              ))
                  .then((value) {
                setState(() {

                  // Pop up message
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                getEnterQty();                                                   // Call getEnterQty function

                // Create a duration for loop to scanSKU function to call again
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              // If got value in DB
              List nonItem = value;                                              // Store DB value in nonItem variable

              // Compare similar value from DB base on ID and line sequence
              var getItem = nonItem.firstWhereOrNull(
                      (element) => element['item_inventory_id'] == itemSku.id
                          && element['line_seq_no'] == selectedItemSequence);

              // Get enter qty value and add by one each time scan
              var newQty = int.parse(getItem['non_tracking_qty'])+1;

              print('TEST: $allPoNonItem');

              // Update the new data into DB
              DBPoNonItem()
                  .update(itemSku.id, newQty.toString(), selectedItemSequence)
                  .then((value) {
                setState(() {
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                getEnterQty();                                                   // Call getEnterQty function
                // Create a duration for loop to scanSKU function to call again
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          // If type scan is not 'scan'

          // Navigate to itemDetail page
          Navigator.of(context).pushNamed(StmsRoutes.poItemDetail).then((value){
            // Create duration for loop to call getEnterQty function
            var _duration = Duration(seconds: 1);
            return Timer(_duration, getEnterQty);
          });
        }
      }
    });
  }

  // Function for search SKU after scan SKU
  searchUPC(String skuBarcode) async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBMasterInventoryHive().getAllInvHive().then((value) {
      poSkuListing = value;                                                      // Get value from API into poSkuListing variable

      // Compare similar itemName at API
      var itemUpc = poSkuListing.firstWhereOrNull(
              (element) => element.upc == skuBarcode && element.sku == itemName);

      // Check if go value or not at API
      if (null == itemUpc) {
        // If no value
        ErrorDialog.showErrorDialog(
            context, 'UPC not match with master inventory');
      } else {
        // If got value
        var nonTrackingType = prefs.getString('nontypeScan');
        // prefs.setString('selectedIvID', selectedItem);
        Storage().selectedInvId = selectedItem;

        // Check the type of scan
        if (nonTrackingType == 'scan') {
          // If type is 'scan'
          // Get data from DB
          DBPoNonItem().getPoNonItem(itemUpc.id, selectedItemSequence).then((value) {
            // Check if got value in DB
            if (value == null) {
              // If no value

              // Create data
              DBPoNonItem()
                  .createPoNonItem(PoNonItem(
                itemInvId: itemUpc.id,
                itemSequence: selectedItemSequence,
                vendorItemName: selectedVendorItem,
                nonTracking: '1',
              ))
                  .then((value) {
                setState(() {

                  // Pop up message
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                getEnterQty();                                                   // Call getEnterQty function
                // Create a duration for loop to scanSKU function to call again
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;                                              // Store DB value in nonItem variable

              // Compare similar value from DB base on ID and line sequence
              var getItem = nonItem.firstWhereOrNull(
                      (element) => element['item_inventory_id'] == itemUpc.id
                          && element['line_seq_no'] == selectedItemSequence);

              // Get enter qty value and add by one each time scan
              var newQty = int.parse(getItem['non_tracking_qty'])+1;

              // Update new data into DB
              DBPoNonItem()
                  .update(itemUpc.id, newQty.toString(), selectedItemSequence)
                  .then((value) {
                getEnterQty();                                                   // Call getEnterQty function

                setState(() {
                  // Call pop up message
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                // Create a duration for loop to scanSKU function to call again
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          // If type scan is not 'scan'
          Navigator.of(context).pushNamed(StmsRoutes.poItemDetail)
              .then((value) {
            // Create a duration for loop to getEnterQty function to call again
            var _duration = Duration(seconds: 1);
            return Timer(_duration, getEnterQty);
          });
        }
      }
    });
  }

  // Function for scan if Serial Number
  Future<void> scanBarcodeNormal() async {

    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);
      print('barcodeScanRes: $barcodeScanRes');

      // Check if scan have value or not
      if (barcodeScanRes != '-1') {
        // If got value
        print('barcode: $barcodeScanRes');
        saveData(barcodeScanRes);                                                // Call saveData function
        // widget.changeView(changeType: ViewChangeType.Forward);
      } else {
        // If no value
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

  // Function to search and save data from Serial number scan
  Future<void> saveData(String barcodeScanRes) async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get value from DB
    DBPoItem().getAllPoItem().then((value) {
      // Check if got value from DB or not
      if (value != null) {
        // If got value in DB

        poItemListing = value;                                                   // Get value from DB into poItemListing variable

        // Compare similar data base on Serial Number and line sequence
        var itemPO = poItemListing.firstWhereOrNull(
                (element) => element['item_serial_no'] == barcodeScanRes
                    && element['line_seq_no'] == selectedItemSequence);

        // Check if there is data from compare value
        if (null == itemPO) {
          // If no data
          prefs.setString("itemBarcode", barcodeScanRes);

          print('ITEM PO1: $itemPO');

          // Navigate to itemDetail page
          Navigator.of(context)
              .pushNamed(StmsRoutes.poItemDetail)
              .then((value) {
            getEnterQty();                                                       // Call getEnterQty function
            // Create a duration for loop to scanBarcodeNormal function to call again
            var _duration = Duration(seconds: 1);
            return Timer(_duration, scanBarcodeNormal);
          });
        } else {
          // If got data

          ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
        }
      } else {
        // If no value in DB
        prefs.setString("itemBarcode", barcodeScanRes);

        // Navigate to itemDetail page
        Navigator.of(context).pushNamed(StmsRoutes.poItemDetail).then((value) {
          // sent update Ent qty result
          getEnterQty();                                                         // Call getEnterQty function
          // Create a duration for loop to scanBarcodeNormal function to call again
          var _duration = Duration(seconds: 1);
          return Timer(_duration, scanBarcodeNormal);
        });
      }
    });
  }

  // Function to view Id and line sequence of item
  viewBarcode(String invNo, String lineSqeNo) async {
    // Get value from DB
    DBPoItem().getBarcodePoItem(invNo, lineSqeNo).then((value) {
      // Check if there is value in DB or not
      if (value == null) {
        // If no value
        ErrorDialog.showErrorDialog(context, 'No Serial No have been scan');
      } else {
        // If got value

        // Store value in getList variable
        var getList = DBPoItem().getBarcodePoItem(invNo, lineSqeNo);
        var getDb = 'DBPoItem';

        // call viewDialog pop up message
        ViewDialog.showViewDialog(context, getList, getDb).whenComplete((){
          setState(() {
            getEnterQty();                                                       // Call getEnterQty function
          });
        });
      }
    });
  }

  // Function to upload to API
  Future<void> uploadData() async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('poId: ${prefs.getString('poId_upload')}');
    var receiptType = prefs.getString('poReceiptType');                          // Get receipt type data into receiptType variable

    // Call and get upload data from DB for PoItem
    DBPoItem().getUpload().then((value) {
      poSerial = value;                                                          // Upload data from DB store into poSerial variable
    });

    // Call and get upload data from DB for PoNonItem
    DBPoNonItem().getUpload().then((value) {
      print('value non Po: $value');
      poNonTrack = value;                                                        // Upload data from DB store into poSerial variable

      // Check if there is data in both poItem and poNonItem
      if (poSerial != null && poNonTrack != null) {
        // If got value

        // Upload both to API
        combineUpdated = []
          ..addAll(poSerial)
          ..addAll(poNonTrack);
      } else if (poSerial == null) {
        // If poItem no value

        // Upload only poNonItem
        combineUpdated = poNonTrack;
      } else {
        // If no value

        // Upload only poItem
        combineUpdated = poSerial;
      }

      print('Value: $combineUpdated');

      // Get value from API
      IncomingService().sendToServer(combineUpdated).then((value) {
        // Check if there is value in API
        if (value['status'] == true) {
          DBPoItem().deleteAllPoItem();                                          // Delete all poItem fromDB
          DBPoNonItem().deleteAllPoNonItem();                                    // Delete all poNonItem from DB

          prefs.remove('povendorNo');                                            // Remove data store for poVendorNo
          prefs.remove('poLocation');                                            // Remove data store for poLocation
          prefs.remove('poId_info');                                             // Remove data store for poID

          // Navigate to purchaseOrder page
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.purchaseOrder));

          // Check if receipt type have value or is 1
          if (receiptType == '1') {
            // If have value or is 1

            // Pop up message
            SuccessDialog.showSuccessDialog(
                context, "Shipment created successfully")
                .then((value) {
              prefs.remove('poReceiptType');                                     // Remove data of poReceiptType
            }); //value['message']
          } else {
            // If n value or value is not 1

            // Pop up message
            SuccessDialog.showSuccessDialog(
                context, "Shipment Invoice created successfully")
                .then((value) {
              prefs.remove('poReceiptType');                                     // Remove data of poReceiptType
            });
          }
        } else {
          // If there is no value on API
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });
  }

  // Function for delete item for poItem in DB
  deletePoItem(String itemInvId, String itemLineSeq) {
    // Get value of delete data from DB
    DBPoItem().deleteSelectedPoItem(itemInvId, itemLineSeq).then((value){
      // Check if got value
      if(value == 1){
        // If got value
        setState(() {

          // Pop up message
          fToast.init(context);
          showCustomSuccess('Reset Successful');

          getEnterQty();                                                         // Call getEnterQty function
        });
      } else {
        // If no value

        // Pop up message
        fToast.init(context);
        showCustomSuccess('Reset Already');
      }
    });
  }

  // Function for delete item for poNonItem in DB
  deletePoNonItem(String itemInvId, String itemLineSeq) {
    // Get value of delete data from DB
    DBPoNonItem().deletePoNonItem(itemInvId, itemLineSeq).then((value){
      // Get value of delete data from DB
      if(value == 1){
        setState(() {
          // If got value
          print('TEST RUN');
          // Pop up message
          fToast.init(context);
          showCustomSuccess('Reset Successful');

          getEnterQty();                                                         // Call getEnterQty function
        });
      } else {
        // If no value

        // Pop up message
        fToast.init(context);
        showCustomSuccess('Reset Already');
      }
    });
  }
}
