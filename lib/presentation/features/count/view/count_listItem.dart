import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/count/count_non_model.dart';
import 'package:stms/data/api/repositories/api_json/api_count.dart';
// import 'package:stms/data/local_db/count/count.dart';
import 'package:stms/data/local_db/count/count_non_scanItem.dart';
import 'package:stms/data/local_db/count/count_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_db.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/card_text.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
// import 'package:stms/presentation/widgets/independent/serial_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';
import 'package:stms/presentation/widgets/independent/view_dialog.dart';

class CountItemListView extends StatefulWidget {
  // final Function changeView;

  const CountItemListView({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _CountItemListViewState createState() => _CountItemListViewState();
}

class _CountItemListViewState extends State<CountItemListView> {
  // final HiveService hiveService = HiveService();
  var getCountItem = CountService();
  late Future<List<Map<String, dynamic>>> _future;
  DateTime date = DateTime.now();
  // bool _isDisable = true;
  List countItemList = [];
  List countItemListing = [];
  List countBarcodeListing = [];
  List serialList = [];
  List scSkuListing = [];
  List scItemListing = [];

  // ignore: unused_field
  String _scanBarcode = 'Unknown';
  var formatDate,
      selectedTxn = '0',
      selectedStatus,
      selectedItem,
      selectedReceipt,
      itemCount,
      infoCount,
      getInfoCount,
      countDate,
      countDoc,
      countSerial,
      countNonTrack,
      combineUpdated,
      itemName;

  @override
  void initState() {
    super.initState();

    // getStock();
    getItemCount();
    // getCommon();
    formatDate = DateFormat('yyyy-MM-dd').format(date);
    // _future = getCountItem.getCountItem();
  }

  // getStock() async {
  //   bool exists = await hiveService.isExists(boxName: "StockTable");
  //   if (exists) {
  //     _future = await hiveService.getBoxes("StockTable");
  //   }
  // }

  getItemCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getCountItem.getCountItem().then((value) {
      setState(() {
        infoCount = prefs.getString('countId_info');
        getInfoCount = json.decode(infoCount);
        countItemList = value;

        countDate = getInfoCount['sc_date'];
        countDoc = getInfoCount['sc_doc'];
        //   print('value info: ${getInfoPO['po_ship_date']}');
      });
    });
  }

  // getCommon() {
  //   DBMasterLocation().getAllMasterLoc().then((value) {
  //     print('value loc: $value');
  //     if (value == null) {
  //       ErrorDialog.showErrorDialog(
  //           context, 'Please download location file at master page first');
  //     } else {
  //       setState(() {
  //         locList = value;
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
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
            body: Container(
              color: Colors.white,
              // height: height * 0.9,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StmsCard(
                    title1: 'Stock Count Date',
                    subtitle1: '$countDate',
                    title2: 'Stock Count Doc',
                    subtitle2: '$countDoc',
                    // title3: 'Ship Date',
                    // subtitle3: '$formatDate',
                    // title4: 'Vendor Name',
                    // subtitle4: '$supplier',
                  ),
                  Container(
                    height: height * 0.65,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      thickness: 5,
                      interactive: true,
                      child: ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Container(
                            // padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder.all(
                                  color: Colors.black, width: 1),
                              columnWidths: const <int, TableColumnWidth>{
                                // 0: FixedColumnWidth(3.0),
                                0: FixedColumnWidth(15.0),
                                1: FixedColumnWidth(75.0),
                                2: FixedColumnWidth(45.0),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      height: 35,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'SKU',
                                        style: TextStyle(fontSize: 16.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    // Text(
                                    //   'SKU',
                                    //   style: TextStyle(fontSize: 16.0),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                    // Text(
                                    //   'PAIV Qty',
                                    //   style: TextStyle(fontSize: 16.0),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                    // Text(
                                    //   'Received Qty',
                                    //   style: TextStyle(fontSize: 16.0),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                    Text(
                                      'Location',
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
                          Container(
                            // height: MediaQuery.of(context).size.height,
                            // padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      // DBPaivNonItem()
                                      //     .getTotal(snapshot.data[index]
                                      //         ['item_inventory_id'])
                                      //     .then((value) {
                                      //   setState(() {
                                      //     print('qty: $value');
                                      //   });
                                      //   //
                                      // });

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
                                            // 0: FixedColumnWidth(3.0),
                                            0: FixedColumnWidth(15.0),
                                            1: FixedColumnWidth(75.0),
                                            2: FixedColumnWidth(45.0),
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                // Container(
                                                //   height: 50,
                                                //   padding: EdgeInsets.fromLTRB(
                                                //       2, 0, 0, 0),
                                                //   child: snapshot.data[index][
                                                //               'tracking_type'] ==
                                                //           "2"
                                                //       ? IconButton(
                                                //           padding:
                                                //               EdgeInsets.all(0),
                                                //           onPressed: () {
                                                //             SerialDialog.showSerialDialog(
                                                //                 context,
                                                //                 snapshot.data[
                                                //                         index][
                                                //                     'serial_list']);
                                                //           },
                                                //           icon: Icon(
                                                //             Icons.search,
                                                //             color: Colors.green,
                                                //           ),
                                                //         )
                                                //       : Container(),
                                                // ),
                                                Text(
                                                  "${snapshot.data[index]['item_name']}",
                                                  style:
                                                      TextStyle(fontSize: 16.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                // Text(
                                                //   "${snapshot.data[index]['item_quantity']}",
                                                //   style:
                                                //       TextStyle(fontSize: 16.0),
                                                //   textAlign: TextAlign.center,
                                                // ),
                                                // Text(
                                                //   "${snapshot.data[index]['item_receive_qty']}",
                                                //   style:
                                                //       TextStyle(fontSize: 16.0),
                                                //   textAlign: TextAlign.center,
                                                // ),
                                                Text(
                                                  "${snapshot.data[index]['item_location_name']}",
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      width: width,
                                                      child: StmsStyleButton(
                                                        title: 'SCAN',
                                                        height: height * 0.05,
                                                        width: width * 0.015,
                                                        backgroundColor:
                                                            Colors.blueAccent,
                                                        textColor: Colors.white,
                                                        onPressed: () async {
                                                          SharedPreferences
                                                              prefs =
                                                              await SharedPreferences
                                                                  .getInstance();

                                                          selectedItem = snapshot
                                                                  .data[index][
                                                              'item_inventory_id'];
                                                          prefs.setString(
                                                              'selectedScID',
                                                              selectedItem);

                                                          prefs.setString(
                                                              'scTracking',
                                                              snapshot.data[
                                                                      index][
                                                                  'tracking_type']);
                                                          var tracking = snapshot
                                                                  .data[index]
                                                              ['tracking_type'];
                                                          var typeScan = 'scan';
                                                          itemName = snapshot
                                                                  .data[index]
                                                              ['item_name'];
                                                          snapshot.data[index][
                                                                      'tracking_type'] ==
                                                                  "2"
                                                              ? serialList =
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      'serial_list']
                                                              : serialList = [];
                                                          checkLocation(
                                                              tracking,
                                                              typeScan);
                                                        },
                                                      ),
                                                    ),
                                                    snapshot.data[index][
                                                                'tracking_type'] ==
                                                            "2"
                                                        ? Column(
                                                            children: [
                                                              Container(
                                                                width: width,
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
                                                                  onPressed:
                                                                      () async {
                                                                    SharedPreferences
                                                                        prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();

                                                                    prefs.setString(
                                                                        'sc_serialList',
                                                                        json.encode(snapshot.data[index]
                                                                            [
                                                                            'serial_list']));

                                                                    selectedItem =
                                                                        snapshot.data[index]
                                                                            [
                                                                            'item_inventory_id'];
                                                                    prefs.setString(
                                                                        'selectedScID',
                                                                        selectedItem);

                                                                    prefs.setString(
                                                                        'scTracking',
                                                                        snapshot.data[index]
                                                                            [
                                                                            'tracking_type']);
                                                                    var tracking =
                                                                        snapshot.data[index]
                                                                            [
                                                                            'tracking_type'];
                                                                    var typeScan =
                                                                        'manual';
                                                                    itemName = snapshot
                                                                            .data[index]
                                                                        [
                                                                        'item_name'];

                                                                    checkLocation(
                                                                      tracking,
                                                                      typeScan,
                                                                    );
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
                                                                          18.0,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
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
                                                              onPressed:
                                                                  () async {
                                                                SharedPreferences
                                                                    prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();

                                                                selectedItem =
                                                                    snapshot.data[
                                                                            index]
                                                                        [
                                                                        'item_inventory_id'];
                                                                prefs.setString(
                                                                    'selectedScID',
                                                                    selectedItem);

                                                                prefs.setString(
                                                                    'scTracking',
                                                                    snapshot.data[
                                                                            index]
                                                                        [
                                                                        'tracking_type']);
                                                                var tracking =
                                                                    snapshot.data[
                                                                            index]
                                                                        [
                                                                        'tracking_type'];
                                                                var typeScan =
                                                                    'manual';
                                                                itemName = snapshot
                                                                            .data[
                                                                        index][
                                                                    'item_name'];
                                                                snapshot.data[index]
                                                                            [
                                                                            'tracking_type'] ==
                                                                        "2"
                                                                    ? serialList =
                                                                        snapshot.data[index]
                                                                            [
                                                                            'serial_list']
                                                                    : serialList =
                                                                        [];
                                                                checkLocation(
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
                            title: 'UPLOAD',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () {
                              uploadData();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future checkLocation(String tracking, String typeScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (tracking == "2" && typeScan == 'scan') {
      scanBarcodeNormal();
    } else if (tracking == "2" && typeScan == 'manual') {
      // Navigator.of(context).pushNamed(StmsRoutes.countItemManual);  ////////// *Create route later
    } else {
      prefs.setString('nontypeScan', typeScan);
      scanSKU();
    }

    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   var paivLocation = prefs.getString('paivLoc');
    //   print('paivLoc: $paivLocation');

    //   if (paivLocation == null) {
    //     return showDialog(
    //       context: context,
    //       builder: (context) {
    //         var height = MediaQuery.of(context).size.height;
    //         // var width = MediaQuery.of(context).size.width;

    //         return AlertDialog(
    //           contentPadding: EdgeInsets.all(10.0),
    //           backgroundColor: Colors.white,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(20),
    //             ),
    //           ),
    //           content: SingleChildScrollView(
    //             child: Container(
    //               height: height * 0.6,
    //               padding: EdgeInsets.all(5),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 crossAxisAlignment: CrossAxisAlignment.center,
    //                 children: [
    //                   Expanded(
    //                     child: Container(
    //                       height: height * 0.42,
    //                       child: FormField<String>(
    //                         builder: (FormFieldState<String> state) {
    //                           return Container(
    //                             // padding: EdgeInsets.symmetric(horizontal: 5),
    //                             child: InputDecorator(
    //                               decoration: InputDecoration(
    //                                 labelText: 'Item Location',
    //                                 errorText:
    //                                     state.hasError ? state.errorText : null,
    //                                 enabledBorder: UnderlineInputBorder(
    //                                   borderSide: BorderSide(color: Colors.white),
    //                                 ),
    //                               ),
    //                               isEmpty: false,
    //                               child: StatefulBuilder(
    //                                 builder: (BuildContext context,
    //                                     StateSetter setState) {
    //                                   return DropdownButtonHideUnderline(
    //                                     child: SearchChoices.single(
    //                                       padding: 10,
    //                                       displayClearIcon: false,
    //                                       icon: Icon(
    //                                         Icons.arrow_drop_down,
    //                                         color: Colors.amber,
    //                                         size: 28,
    //                                       ),
    //                                       // iconEnabledColor: Colors.amberAccent,
    //                                       iconDisabledColor: Colors.grey[350],
    //                                       items: locList.map((item) {
    //                                         return new DropdownMenuItem(
    //                                           child: Text(
    //                                             item['name'],
    //                                             overflow: TextOverflow.ellipsis,
    //                                           ),
    //                                           value: item['name'],
    //                                         );
    //                                       }).toList(),
    //                                       value: selectedLoc,
    //                                       onChanged: (value) {
    //                                         setState(() {
    //                                           selectedLoc = value;
    //                                           var locId = locList
    //                                               .firstWhereOrNull((element) =>
    //                                                   element['name'] == value);
    //                                           locationId = locId['id'];
    //                                         });
    //                                       },
    //                                       isExpanded: true,
    //                                       searchInputDecoration: InputDecoration(
    //                                         border: OutlineInputBorder(),
    //                                       ),
    //                                       selectedValueWidgetFn: (item) {
    //                                         return Container(
    //                                           alignment: Alignment.centerLeft,
    //                                           padding: const EdgeInsets.all(0),
    //                                           child: Text(
    //                                             item.toString(),
    //                                             overflow: TextOverflow.ellipsis,
    //                                           ),
    //                                         );
    //                                       },
    //                                     ),
    //                                   );
    //                                 },
    //                               ),
    //                             ),
    //                           );
    //                         },
    //                       ),
    //                     ),
    //                   ),
    //                   Expanded(
    //                     child: Align(
    //                       alignment: Alignment.bottomCenter,
    //                       child: Padding(
    //                         padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
    //                         child: ButtonTheme(
    //                           minWidth: 200,
    //                           height: 50,
    //                           child: StmsStyleButton(
    //                             title: 'SELECT',
    //                             backgroundColor: Colors.amber,
    //                             textColor: Colors.black,
    //                             onPressed: () async {
    //                               if (selectedLoc == null) {
    //                                 ErrorDialog.showErrorDialog(
    //                                     context, 'Please select Location');
    //                               } else {
    //                                 SharedPreferences prefs =
    //                                     await SharedPreferences.getInstance();
    //                                 prefs.setString('paivLoc', locationId);

    //                                 Navigator.pop(context);

    //                                 if (tracking == "2" && typeScan == 'scan') {
    //                                   scanBarcodeNormal();
    //                                 } else if (tracking == "2" &&
    //                                     typeScan == 'manual') {
    //                                   Navigator.of(context)
    //                                       .pushNamed(StmsRoutes.paivItemManual);
    //                                 } else {
    //                                   prefs.setString('nontypeScan', typeScan);
    //                                   scanSKU();
    //                                   // Navigator.of(context)
    //                                   //     .pushNamed(StmsRoutes.poItemDetail);
    //                                 }
    //                               }
    //                             },
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //         );
    //       },
    //     );
    //   } else {
    //     if (tracking == "2" && typeScan == 'scan') {
    //       scanBarcodeNormal();
    //     } else if (tracking == "2" && typeScan == 'manual') {
    //       Navigator.of(context).pushNamed(StmsRoutes.paivItemManual);
    //     } else {
    //       prefs.setString('nontypeScan', typeScan);
    //       scanSKU();
    //     }
    //   }
  }

  Future<void> scanSKU() async {
    String skuBarcode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      skuBarcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);
      print('skuBarcode: $skuBarcode');
      if (skuBarcode != '-1') {
        print('barcode: $skuBarcode');
        searchSKU(skuBarcode);
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

  searchSKU(String skuBarcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBMasterInventory().getAllMasterInv().then((value) {
      // scSkuListing = value;
      var itemSku = scSkuListing.firstWhereOrNull((element) =>
          element['sku'] == skuBarcode && element['sku'] == itemName);

      if (null == itemSku) {
        ErrorDialog.showErrorDialog(
            context, 'SKU not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');

        if (nonTrackingType == 'scan') {
          DBCountNonItem().getCountNonItem(selectedItem).then((value) {
            print('value non $value');
            if (value == null) {
              DBCountNonItem()
                  .createCountNonItem(CountNonItem(
                itemInvId: selectedItem,
                nonTracking: '1',
                itemReason: '',
                itemLocation: '',
              ))
                  .then((value) {
                // SuccessDialog.showSuccessDialog(context, 'Item Save');
                showSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                  (element) => element['item_inventory_id'] == selectedItem);

              print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty']) + 1;
              print('newQty: $newQty');
              DBCountNonItem()
                  .update(selectedItem, newQty.toString())
                  .then((value) {
                showSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          Navigator.of(context).pushNamed(StmsRoutes.countItemDetail);
        }
      }
    });
  }

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

    // paivSerialNo = getInfoPaiv['items'];
    var itemSerial =
        serialList.firstWhereOrNull((element) => element == barcodeScanRes);
    print('serialNo: $itemSerial');

    if (null == itemSerial) {
      ErrorDialog.showErrorDialog(context, 'Serial No. not match');
    } else {
      DBCountItem().getAllCountItem().then((value) {
        if (value != null) {
          scItemListing = value;
          // print('item Serial list: $value');

          var itemCount = scItemListing.firstWhereOrNull(
              (element) => element['item_serial_no'] == barcodeScanRes);
          if (null == itemCount) {
            prefs.setString("itemBarcode", barcodeScanRes);

            Navigator.of(context)
                .pushNamed(StmsRoutes.countItemDetail)
                .then((value) {
              setState(() {
                scanBarcodeNormal();
              });
            });
          } else {
            ErrorDialog.showErrorDialog(context, 'Serial No. already exists.');
          }
        } else {
          prefs.setString("itemBarcode", barcodeScanRes);

          Navigator.of(context)
              .pushNamed(StmsRoutes.countItemDetail)
              .then((value) {
            setState(() {
              scanBarcodeNormal();
            });
          });
        }
      });
    }
  }

  viewBarcode(String invNo) async {
    DBCountItem().getBarcodeCountItem(invNo).then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(context, 'No Serial No have been scan');
      } else {
        var getList = DBCountItem().getBarcodeCountItem(invNo);
        var getDb = 'DBCountItem';
        ViewDialog.showViewDialog(context, getList, getDb);
      }
    });
  }

  Future<void> uploadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('paivId: ${prefs.getString('poivId_upload')}');

    DBCountItem().getUpload().then((value) {
      // print('value serial po: $value');
      countSerial = value;
    });

    DBCountNonItem().getUpload().then((value) {
      // print('value non Po: $value');
      countNonTrack = value;
      if (countSerial != null && countNonTrack != null) {
        combineUpdated = []
          ..addAll(countSerial)
          ..addAll(countNonTrack);
      } else if (countSerial == null) {
        combineUpdated = countNonTrack;
      } else {
        combineUpdated = countSerial;
      }

      CountService().sendToServer(combineUpdated).then((value) {
        if (value['status'] == true) {
          DBCountItem().deleteAllCountItem();
          DBCountNonItem().deleteAllCountNonItem();
          prefs.remove('countId_info');
          // prefs.remove('paivLoc');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.countView));
          SuccessDialog.showSuccessDialog(
              context, "Stock Count created successfully"); // value['message']
        } else {
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });
  }
}


// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:collection/collection.dart';

// import 'package:stms/config/routes.dart';
// import 'package:stms/data/api/repositories/api_json/api_count.dart';
// import 'package:stms/data/local_db/count/count_non_scanItem.dart';
// import 'package:stms/data/local_db/count/count_scanItem.dart';
// import 'package:stms/presentation/features/profile/profile.dart';
// import 'package:stms/presentation/widgets/independent/error_dialog.dart';
// import 'package:stms/presentation/widgets/independent/input_field.dart';
// import 'package:stms/presentation/widgets/independent/scaffold.dart';
// import 'package:stms/presentation/widgets/independent/style_button.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stms/presentation/widgets/independent/success_dialog.dart';
// import 'package:stms/presentation/widgets/independent/view_dialog.dart';

// class CountItemListView extends StatefulWidget {
//   // final Function changeView;

//   const CountItemListView({Key? key})
//       : super(key: key); //, required this.changeView

//   @override
//   _CountItemListViewState createState() => _CountItemListViewState();
// }

// class _CountItemListViewState extends State<CountItemListView> {
//   var getCountItem = CountService();
//   late Future<List<Map<String, dynamic>>> _future;
//   DateTime date = DateTime.now();
//   // bool _isDisable = true;
//   List countItemList = [];
//   List countItemListing = [];
//   List countBarcodeListing = [];

//   // ignore: unused_field
//   String _scanBarcode = 'Unknown';
//   var formatDate,
      // selectedTxn = '0',
      // selectedStatus,
      // selectedItem,
      // selectedReceipt,
      // itemCount,
      // infoCount,
      // getInfoCount,
      // countDate,
      // countDoc,
      // countSerial,
      // countNonTrack,
      // combineUpdated;
//   final format = DateFormat("yyyy-MM-dd");
//   final TextEditingController vendorNoController = TextEditingController();
//   final GlobalKey<StmsInputFieldState> vendorNoKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();

//     formatDate = DateFormat('yyyy-MM-dd').format(date);
//     getItemCount();
//     // checkBarcodeList();
//     _future = getCountItem.getCountItem();
//   }

//   getItemCount() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     getCountItem.getCountItem().then((value) {
//       setState(() {
//         infoCount = prefs.getString('countId_info');
//         getInfoCount = json.decode(infoCount);
//         countItemList = value;

//         countDate = getInfoCount['sc_date'];
//         countDoc = getInfoCount['sc_doc'];
//         //   print('value info: ${getInfoPO['po_ship_date']}');
//       });
//     });
//   }

//   // checkBarcodeList() {
//   //   DBPoItem().getBarcodePoItem().then((value) {
//   //     print('getbarcode: $value');
//   //     if (value != null) {
//   //       setState(() {
//   //         _isDisable = false;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _isDisable = true;
//   //       });
//   //     }
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;

//     return SafeArea(
//       child: BlocBuilder<ProfileBloc, ProfileState>(
//         builder: (context, state) {
//           if (state is ProfileProcessing) {
//             return Container(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               color: Colors.white,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//           return StmsScaffold(
//             title: '',
//             body: Container(
//               color: Colors.white,
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: height * 0.1,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Stock Count Date: $countDate",
//                           style: TextStyle(fontSize: 18),
//                           textAlign: TextAlign.left,
//                         ),
//                         Text("Stock Count Doc: $countDoc",
//                             style: TextStyle(fontSize: 18)),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: height * 0.75,
//                     child: ListView(
//                       shrinkWrap: true,
//                       physics: AlwaysScrollableScrollPhysics(),
//                       children: [
//                         Container(
//                           child: Table(
//                             defaultVerticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             border:
//                                 TableBorder.all(color: Colors.black, width: 1),
//                             columnWidths: const <int, TableColumnWidth>{
//                               0: FixedColumnWidth(30.0),
//                               1: FixedColumnWidth(100.0),
//                               2: FixedColumnWidth(100.0),
//                             },
//                             children: [
//                               TableRow(
//                                 children: [
//                                   Container(
//                                     height: 35,
//                                     child: Text(
//                                       'Inv ID',
//                                       style: TextStyle(
//                                         fontSize: 16.0,
//                                         // height: 1.8,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Item Name',
//                                     style: TextStyle(fontSize: 16.0),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   Text(
//                                     'Item Location',
//                                     style: TextStyle(fontSize: 16.0),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   Text(
//                                     ' ',
//                                     style: TextStyle(fontSize: 16.0),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           child: FutureBuilder(
//                             future: _future,
//                             builder:
//                                 (BuildContext context, AsyncSnapshot snapshot) {
//                               if (!snapshot.hasData) {
//                                 return Center(
//                                   child: CircularProgressIndicator(),
//                                 );
//                               } else {
//                                 return ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: snapshot.data.length,
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     return Material(
//                                       // color: index % 2 == 0 ? Colors.white : Colors.grey[400],
//                                       child: Table(
//                                         border: TableBorder.all(
//                                           color: Colors.black,
//                                           width: 0.2,
//                                         ),
//                                         defaultVerticalAlignment:
//                                             TableCellVerticalAlignment.middle,
//                                         columnWidths: const <int,
//                                             TableColumnWidth>{
//                                           0: FixedColumnWidth(30.0),
//                                           1: FixedColumnWidth(100.0),
//                                           2: FixedColumnWidth(100.0),
//                                         },
//                                         children: [
//                                           TableRow(
//                                             children: [
//                                               Container(
//                                                 height: 50,
//                                                 padding: EdgeInsets.fromLTRB(
//                                                     2, 0, 0, 0),
//                                                 child: Text(
//                                                   "${snapshot.data[index]['item_inventory_id']}",
//                                                   style: TextStyle(
//                                                     fontSize: 16.0,
//                                                     height: 2.3,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 5),
//                                                 child: Text(
//                                                   "${snapshot.data[index]['item_name']}",
//                                                   style:
//                                                       TextStyle(fontSize: 16.0),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 5),
//                                                 child: Text(
//                                                   "${snapshot.data[index]['item_location_name']}",
//                                                   style:
//                                                       TextStyle(fontSize: 16.0),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 5),
//                                                 child: Column(
//                                                   children: [
//                                                     Container(
//                                                       width: width,
//                                                       child: StmsStyleButton(
//                                                         title: snapshot.data[
//                                                                         index][
//                                                                     'tracking_type'] ==
//                                                                 "2"
//                                                             ? 'SCAN'
//                                                             : 'ENTER',
//                                                         height: height * 0.05,
//                                                         width: width * 0.013,
//                                                         backgroundColor:
//                                                             Colors.blueAccent,
//                                                         textColor: Colors.white,
//                                                         onPressed: () async {
//                                                           SharedPreferences
//                                                               prefs =
//                                                               await SharedPreferences
//                                                                   .getInstance();

//                                                           selectedItem = snapshot
//                                                                   .data[index][
//                                                               'item_inventory_id'];
//                                                           prefs.setString(
//                                                               'selectedIvID',
//                                                               selectedItem);

//                                                           var tracking = snapshot
//                                                                   .data[index]
//                                                               ['tracking_type'];

//                                                           prefs.setString(
//                                                               'countTracking',
//                                                               tracking);

//                                                           if (tracking == "2") {
//                                                             scanBarcodeNormal();
//                                                           } else {
//                                                             Navigator.of(
//                                                                     context)
//                                                                 .pushNamed(
//                                                                     StmsRoutes
//                                                                         .countItemDetail);
//                                                           }
//                                                         },
//                                                       ),
//                                                     ),
//                                                     snapshot.data[index][
//                                                                 'tracking_type'] ==
//                                                             "2"
//                                                         ? Container(
//                                                             width: width,
//                                                             child:
//                                                                 ElevatedButton(
//                                                               style:
//                                                                   ElevatedButton
//                                                                       .styleFrom(
//                                                                 primary: Colors
//                                                                     .green,
//                                                                 minimumSize: Size(
//                                                                     width *
//                                                                         0.015,
//                                                                     height *
//                                                                         0.05),
//                                                               ),
//                                                               onPressed: () {
//                                                                 viewBarcode(snapshot
//                                                                             .data[
//                                                                         index][
//                                                                     'item_inventory_id']);
//                                                               },
//                                                               child: Text(
//                                                                 'VIEW',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       18.0,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           )
//                                                         : Container(),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       alignment: Alignment.bottomCenter,
//                       child: Padding(
//                         padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//                         child: ButtonTheme(
//                           minWidth: 200,
//                           height: 50,
//                           child: StmsStyleButton(
//                             title: 'UPLOAD',
//                             backgroundColor: Colors.amber,
//                             textColor: Colors.black,
//                             onPressed: () {
//                               uploadData();
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> scanBarcodeNormal() async {
//     String barcodeScanRes;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//           '#ff6666', '', true, ScanMode.BARCODE);
//       print('barcodeScanRes: $barcodeScanRes');
//       if (barcodeScanRes != '-1') {
//         print('barcode: $barcodeScanRes');
//         saveData(barcodeScanRes);
//         // widget.changeView(changeType: ViewChangeType.Forward);
//       } else {
//         ErrorDialog.showErrorDialog(context, 'No barcode/qrcode detected');
//       }
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _scanBarcode = barcodeScanRes;
//     });
//   }

//   Future<void> saveData(String barcodeScanRes) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     DBCountItem().getAllCountItem().then((value) {
//       if (value != null) {
//         countItemListing = value;

//         var itemCount = countItemListing.firstWhereOrNull(
//             (element) => element['item_serial_no'] == barcodeScanRes);
//         if (null == itemCount) {
//           prefs.setString("itemBarcode", barcodeScanRes);

//           Navigator.of(context).pushNamed(StmsRoutes.countItemDetail);
//         } else {
//           ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
//         }
//       } else {
//         // prefs.setString("itemSelect", json.encode(item));
//         prefs.setString("itemBarcode", barcodeScanRes);

//         // await Future.delayed(const Duration(seconds: 3));
//         Navigator.of(context).pushNamed(StmsRoutes.countItemDetail);
//         //   .whenComplete(() {
//         // setState(() {
//         //   checkBarcodeList();
//         // });
//         // });
//       }
//     });
//   }

//   viewBarcode(String invNo) async {
//     print('inv count: $invNo');
//     DBCountItem().getBarcodeCountItem(invNo).then((value) {
//       if (value == null) {
//         ErrorDialog.showErrorDialog(context, 'No Serial No have been scan');
//       } else {
//         var getList = DBCountItem().getBarcodeCountItem(invNo);
//         var getDb = 'DBCountItem';
//         ViewDialog.showViewDialog(context, getList, getDb);
//       }
//     });
//   }

//   Future<void> uploadData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     print('countId: ${prefs.getString('countId_upload')}');

//     DBCountItem().getUpload().then((value) {
//       // print('value serial po: $value');
//       countSerial = value;
//     });

//     DBCountNonItem().getUpload().then((value) {
//       // print('value non count: $value');
//       countNonTrack = value;
//       if (countSerial != null && countNonTrack != null) {
//         combineUpdated = []
//           ..addAll(countSerial)
//           ..addAll(countNonTrack);
//       } else if (countSerial == null) {
//         combineUpdated = countNonTrack;
//       } else {
//         combineUpdated = countSerial;
//       }

//       CountService().sendToServer(combineUpdated).then((value) {
//         if (value['status'] == true) {
//           DBCountItem().deleteAllCountItem();
//           DBCountNonItem().deleteAllCountNonItem();
//           prefs.remove('countId_info');
//           Navigator.popUntil(
//               context, ModalRoute.withName(StmsRoutes.stockCount));
//           SuccessDialog.showSuccessDialog(context, value['message']);
//         } else {
//           ErrorDialog.showErrorDialog(context, value['message']);
//         }
//       });
//     });
//   }
// }
