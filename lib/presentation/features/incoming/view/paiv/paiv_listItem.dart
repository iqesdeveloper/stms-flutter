import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/incoming/paiv/paiv_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_paiv.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_scanItem_db.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/card_text.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/serial_dialog.dart';
import 'package:stms/presentation/widgets/independent/skuUpc_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';
import 'package:stms/presentation/widgets/independent/view_dialog.dart';

class PaivItemListView extends StatefulWidget {
  // final Function changeView;

  const PaivItemListView({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _PaivItemListViewState createState() => _PaivItemListViewState();
}

class _PaivItemListViewState extends State<PaivItemListView> {
  DateTime date = DateTime.now();
  var getPaivItem = PaivService();
  late Future<List<Map<String, dynamic>>> _future;
  // bool _isDisable = true;
  List paivItemList = [];
  List paivItemListing = [];
  List<InventoryHive> paivSkuListing = [];
  List paivSerialNo = [];
  List locList = [];
  List serialList = [];
  List allPaivItem = [];
  List allPaivNonItem = [];
  // ignore: unused_field
  String _scanBarcode = 'Unknown';

  var formatDate,
      selectedItem,
      selectedLoc,
      itemPaiv,
      infoPaiv,
      getInfoPaiv,
      paivDoc,
      paivDate,
      supplier,
      paivSerial,
      paivNonTrack,
      combineUpdated,
      itemName,
      locationId;

  @override
  void initState() {
    super.initState();

    getItemPaiv();
    getCommon();
    // call the enterQty whenever at start of this page
    getEnterQty();
    formatDate = DateFormat('yyyy-MM-dd').format(date);
    _future = getPaivItem.getPaivItem();

    fToast = FToast();
    fToast.init(context);
  }

  Future<void> getItemPaiv() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getPaivItem.getPaivItem().then((value) {
      setState(() {
        infoPaiv = prefs.getString('paiv_info');
        getInfoPaiv = json.decode(infoPaiv);
        paivItemList = value;

        paivDate = getInfoPaiv['paiv_date'];
        paivDoc = getInfoPaiv['paiv_trdn'];
        supplier = getInfoPaiv['supplier_name'];
        // print('paiv value view: $value');
      });
    });
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

  // check and get all the purchase order item and purchase order non item
  // POItem & PoNonItem
  getEnterQty() {
    DBPaivItem().getAllPaivItem().then((value) {
      // make the PoItem is equal to the item store in scanDB
      // It is the save info
      setState(() {
        allPaivItem = value;
      });
    });

    DBPaivNonItem().getAllPaivNonItem().then((value) {
      setState(() {
        // Display and get all the PoNonItem after scanDB collected.
        // It is the save info
        allPaivNonItem = value;
      });
    });
  }

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
                    title1: 'PAIV Doc No.',
                    subtitle1: '$paivDoc',
                    title2: 'Date',
                    subtitle2: '$paivDate',
                    title3: 'Ship Date',
                    subtitle3: '$formatDate',
                    title4: 'Vendor Name',
                    subtitle4: '$supplier',
                  ),
                  Container(
                    height: height * 0.65,
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Container(
                          // padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            border:
                                TableBorder.all(color: Colors.black, width: 1),
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
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        // height: 1.8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    'SKU',
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'PAIV Qty',
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
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
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
                                                height: 50,
                                                padding: EdgeInsets.fromLTRB(
                                                    2, 0, 0, 0),
                                                child: snapshot.data[index]
                                                            ['tracking_type'] ==
                                                        "2"
                                                    ? IconButton(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        onPressed: () {
                                                          SerialDialog
                                                              .showSerialDialog(
                                                                  context,
                                                                  snapshot.data[
                                                                          index]
                                                                      [
                                                                      'serial_list']);
                                                        },
                                                        icon: Icon(
                                                          Icons.search,
                                                          color: Colors.green,
                                                        ),
                                                      )
                                                    : Container(),
                                              ),
                                              Text(
                                                "${snapshot.data[index]['item_name']}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "${snapshot.data[index]['item_quantity']}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "${snapshot.data[index]['item_receive_qty']}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              // Enter Quantity text
                                              // Will display whether it pass in the value or not
                                              // This s to check if Enter Quantity got value
                                              // using the master file snapshot check
                                              // THIS IS FOR ALLPAIVITEM
                                              snapshot.data[index]['tracking_type'] == "2" ? Text(
                                                // to check if allPoItem got value or not
                                                // If got value, check in the master file snapshot and compare the item_inventory_id
                                                // Using the 'where' will go through the check process like a looping
                                                allPaivItem.isNotEmpty ? allPaivItem.where((element)
                                                => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']).isNotEmpty
                                                // once check, if it is containing a value or the item_id in DB is same in the master file
                                                // Get the length of the item_id
                                                    ? '${allPaivItem.where((element) => element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']).length}'
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
                                                // ALLPAIVNONITEM section
                                                // Need to check if there is a value after scan.
                                                // Comparing both the DB and master file to check if there is a value before and after scan
                                                allPaivNonItem.isNotEmpty ? allPaivNonItem.firstWhereOrNull((element) =>
                                                element['item_inventory_id'] == snapshot.data[index]['item_inventory_id']) != null
                                                // If got value, then display the tracking_qty
                                                    ? "${allPaivNonItem.firstWhereOrNull((element) => element['item_inventory_id']
                                                    == snapshot.data[index]['item_inventory_id'])['non_tracking_qty']}"
                                                // If no value after scan, which means it is not the same as in DB, then display '0'
                                                    : "0"
                                                // This is generally display '0' if no value is found
                                                    : "0",
                                                style: TextStyle(
                                                    fontSize: 16.0
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

                                                        selectedItem = snapshot.data[index]['item_name'];
                                                        prefs.setString('selectedPaIvID', selectedItem);

                                                        prefs.setString('paivTracking', snapshot.data[index]['tracking_type']);
                                                        var tracking = snapshot.data[index]['tracking_type'];
                                                        var typeScan = 'scan';
                                                        itemName = snapshot.data[index]['item_name'];
                                                        snapshot.data[index]['tracking_type'] == "2"
                                                            ? serialList =
                                                                snapshot.data[index]['serial_list']
                                                            : serialList = [];

                                                        snapshot.data[index][
                                                                    'tracking_type'] ==
                                                                "2"
                                                            ? checkLocation(
                                                                tracking,
                                                                typeScan)
                                                            : SkuUpcDialog
                                                                    .showSkuUpcDialog(
                                                                        context)
                                                                .then((value) {
                                                                checkLocation(
                                                                    tracking,
                                                                    typeScan);
                                                              });
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
                                                                      await SharedPreferences.getInstance();

                                                                  prefs.setString('paiv_serialList', json.encode(snapshot.data[index]['serial_list']));

                                                                  selectedItem = snapshot.data[index]['item_name'];
                                                                  prefs.setString('selectedPaIvID', selectedItem);

                                                                  prefs.setString('paivTracking', snapshot.data[index]['tracking_type']);
                                                                  var tracking = snapshot.data[index]['tracking_type'];
                                                                  var typeScan = 'manual';
                                                                  itemName = snapshot.data[index]['item_name'];

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
                                                                onPressed: () {
                                                                  viewBarcode(
                                                                      snapshot.data[index]['item_inventory_id']);
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
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              primary: Colors
                                                                  .blueAccent,
                                                              minimumSize: Size(
                                                                  width * 0.015,
                                                                  height *
                                                                      0.05),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              SharedPreferences
                                                                  prefs =
                                                                  await SharedPreferences.getInstance();

                                                              selectedItem = snapshot.data[index]['item_name'];
                                                              prefs.setString('selectedPaIvID', selectedItem);

                                                              prefs.setString('paivTracking', snapshot.data[index]['tracking_type']);
                                                              var tracking = snapshot.data[index]['tracking_type'];
                                                              var typeScan = 'manual';itemName = snapshot.data[index]['item_name'];
                                                              snapshot.data[index]['tracking_type'] == "2"
                                                                  ? serialList =
                                                                      snapshot.data[
                                                                              index]
                                                                          [
                                                                          'serial_list']
                                                                  : serialList =
                                                                      [];

                                                              SkuUpcDialog
                                                                      .showSkuUpcDialog(
                                                                          context)
                                                                  .then(
                                                                      (value) {
                                                                checkLocation(
                                                                    tracking,
                                                                    typeScan);
                                                              });
                                                            },
                                                            child: Text(
                                                              'MANUAL',
                                                              style: TextStyle(
                                                                fontSize: 16.0,
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
    var paivLocation = prefs.getString('paivLoc');
    print('paivLoc: $paivLocation');

    if (paivLocation == null) {
      return showDialog(
        context: context,
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          // var width = MediaQuery.of(context).size.width;

          return AlertDialog(
            contentPadding: EdgeInsets.all(10.0),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                height: height * 0.6,
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: height * 0.42,
                        child: FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return Container(
                              // padding: EdgeInsets.symmetric(horizontal: 5),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Item Location',
                                  errorText:
                                      state.hasError ? state.errorText : null,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                isEmpty: false,
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return DropdownButtonHideUnderline(
                                      child: SearchChoices.single(
                                        padding: 10,
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
                                            var locId = locList
                                                .firstWhereOrNull((element) =>
                                                    element['name'] == value);
                                            locationId = locId['id'];
                                          });
                                        },
                                        isExpanded: true,
                                        searchInputDecoration: InputDecoration(
                                          border: OutlineInputBorder(),
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
                              ),
                            );
                          },
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
                              onPressed: () async {
                                if (selectedLoc == null) {
                                  ErrorDialog.showErrorDialog(
                                      context, 'Please select Location');
                                } else {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('paivLoc', locationId);

                                  Navigator.pop(context);

                                  if (tracking == "2" && typeScan == 'scan') {
                                    scanBarcodeNormal();
                                  } else if (tracking == "2" &&
                                      typeScan == 'manual') {
                                    Navigator.of(context)
                                        .pushNamed(StmsRoutes.paivItemManual).then((value){
                                      getEnterQty();
                                    });
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
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      if (tracking == "2" && typeScan == 'scan') {
        scanBarcodeNormal();
      } else if (tracking == "2" && typeScan == 'manual') {
        Navigator.of(context).pushNamed(StmsRoutes.paivItemManual).then((value){
          getEnterQty();
        });
      } else {
        prefs.setString('nontypeScan', typeScan);
        scanSKU();
      }
    }
  }

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

  searchSKU(String skuBarcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // DBMasterInventory().getAllMasterInv().then((value) async {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      paivSkuListing = value;

      var itemSku = paivSkuListing.firstWhereOrNull(
          (element) => element.sku == skuBarcode && element.sku == itemName);

      if (null == itemSku) {
        ErrorDialog.showErrorDialog(
            context, 'SKU not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');
        prefs.setString('selectedIvID', selectedItem);

        if (nonTrackingType == 'scan') {
          DBPaivNonItem().getPaivNonItem(itemSku.id).then((value) {
            print('value non $value');
            if (value == null) {
              DBPaivNonItem()
                  .createPaivNonItem(PaivNonItem(
                itemInvId: itemSku.id,
                nonTracking: '1',
              ))
                  .then((value) {
                // SuccessDialog.showSuccessDialog(context, 'Item Save');
                setState(() {
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                // call and update the enterQty function
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                  (element) => element['item_inventory_id'] == itemSku.id);

              print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty']) + 1;
              print('newQty: $newQty');
              DBPaivNonItem()
                  .update(itemSku.id, newQty.toString())
                  .then((value) {
                setState(() {
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                // call and update the enterQty function
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          // await Future.delayed(const Duration(seconds: 2));
          Navigator.of(context).pushNamed(StmsRoutes.paivItemDetail).then((value){
            var _duration = Duration(seconds: 1);
            return Timer(_duration, getEnterQty);
          });
        }
      }
    });
  }

  searchUPC(String skuBarcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // DBMasterInventory().getAllMasterInv().then((value) async {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      paivSkuListing = value;

      var itemSku = paivSkuListing.firstWhereOrNull(
          (element) => element.upc == skuBarcode && element.sku == itemName);

      if (null == itemSku) {
        ErrorDialog.showErrorDialog(
            context, 'UPC not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');
        prefs.setString('selectedIvID', selectedItem);

        if (nonTrackingType == 'scan') {
          DBPaivNonItem().getPaivNonItem(itemSku.id).then((value) {
            print('value non $value');
            if (value == null) {
              DBPaivNonItem()
                  .createPaivNonItem(PaivNonItem(
                itemInvId: itemSku.id,
                nonTracking: '1',
              ))
                  .then((value) {
                // SuccessDialog.showSuccessDialog(context, 'Item Save');
                setState(() {
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                // call and update the enterQty function
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                  (element) => element['item_inventory_id'] == itemSku.id);

              print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty']) + 1;
              print('newQty: $newQty');
              DBPaivNonItem()
                  .update(itemSku.id, newQty.toString())
                  .then((value) {
                setState(() {
                  fToast.init(context);
                  showCustomSuccess('Item Save');
                });
                // call and update the enterQty function
                getEnterQty();
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          // await Future.delayed(const Duration(seconds: 2));
          Navigator.of(context).pushNamed(StmsRoutes.paivItemDetail).then((value){
            var _duration = Duration(seconds: 1);
            return Timer(_duration, getEnterQty);
          });
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

    if (itemSerial == null) {
      ErrorDialog.showErrorDialog(context, 'Serial No. not match');
    } else {
      DBPaivItem().getAllPaivItem().then((value) {
        if (value != null) {
          paivItemListing = value;
          // print('item Serial list: $value');

          var itemPaiv = paivItemListing.firstWhereOrNull(
              (element) => element['item_serial_no'] == barcodeScanRes);
          if (null == itemPaiv) {
            prefs.setString("itemBarcode", barcodeScanRes);

            Navigator.of(context)
                .pushNamed(StmsRoutes.paivItemDetail)
                .then((value) {
              // sent update Ent qty result
              getEnterQty();
              var _duration = Duration(seconds: 1);
              return Timer(_duration, scanBarcodeNormal);
            });
          } else {
            ErrorDialog.showErrorDialog(context, 'Serial No. already exists.');
          }
        } else {
          prefs.setString("itemBarcode", barcodeScanRes);

          Navigator.of(context)
              .pushNamed(StmsRoutes.paivItemDetail)
              .then((value) {
            // sent update Ent qty result
            getEnterQty();
            var _duration = Duration(seconds: 1);
            return Timer(_duration, scanBarcodeNormal);
          });
        }
      });
    }
  }

  viewBarcode(String invNo) async {
    DBPaivItem().getBarcodePaivItem(invNo).then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(context, 'No Serial No have been scan');
      } else {
        var getList = DBPaivItem().getBarcodePaivItem(invNo);
        var getDb = 'DBPaivItem';
        ViewDialog.showViewDialog(context, getList, getDb);
      }
    });
  }

  Future<void> uploadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('paivId: ${prefs.getString('poivId_upload')}');

    DBPaivItem().getUpload().then((value) {
      // print('value serial po: $value');
      paivSerial = value;
    });

    DBPaivNonItem().getUpload().then((value) {
      // print('value non Po: $value');
      paivNonTrack = value;
      if (paivSerial != null && paivNonTrack != null) {
        combineUpdated = []
          ..addAll(paivSerial)
          ..addAll(paivNonTrack);
      } else if (paivSerial == null) {
        combineUpdated = paivNonTrack;
      } else {
        combineUpdated = paivSerial;
      }

      PaivService().sendToServer(combineUpdated, formatDate).then((value) {
        if (value['status'] == true) {
          DBPaivItem().deleteAllPaivItem();
          DBPaivNonItem().deleteAllPaivNonItem();
          prefs.remove('paiv_info');
          prefs.remove('paivLoc');
          Navigator.popUntil(context, ModalRoute.withName(StmsRoutes.paivView));
          SuccessDialog.showSuccessDialog(
              context, "PAIV Return created successfully"); // value['message']
        } else {
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });
  }
}
