import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/models/outgoing/si/si_non_model.dart';
import 'package:stms/data/api/repositories/api_json/api_out_saleInvoice.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/outgoing/si/si_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/si/si_scanItem.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/card_text.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/serial_dialog.dart';
import 'package:stms/presentation/widgets/independent/skuUpc_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';
import 'package:stms/presentation/widgets/independent/view_dialog.dart';

class SiItemListView extends StatefulWidget {
  // final Function changeView;

  const SiItemListView({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _SiItemListViewState createState() => _SiItemListViewState();
}

class _SiItemListViewState extends State<SiItemListView> {
  var getSaleInvoiceItem = SaleInvoiceService();
  late Future<List<Map<String, dynamic>>> _future;
  // bool _isDisable = true;
  List locList = [];
  List siSerialNo = [];
  List siItemList = [];
  List siItemListing = [];
  List<InventoryHive> siSkuListing = [];
  List serialList = [];
  // ignore: unused_field
  String _scanBarcode = 'Unknown';

  var selectedItem,
      selectedLoc,
      itemSi,
      infoSi,
      getInfoSi,
      siDoc,
      siDate,
      customer,
      siSerial,
      siNonTrack,
      combineUpdated,
      itemName,
      locationId;

  @override
  void initState() {
    super.initState();

    getItemSi();
    getCommon();
    _future = getSaleInvoiceItem.getSiItem();
  }

  Future<void> getItemSi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getSaleInvoiceItem.getSiItem().then((value) {
      setState(() {
        infoSi = prefs.getString('si_info');
        getInfoSi = json.decode(infoSi);
        siItemList = value;

        siDoc = getInfoSi['si_doc'];
        siDate = getInfoSi['si_date'];
        customer = getInfoSi['customer_name'];

        print('si date: $siDate');
        print('si customer: $customer');
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
            body: SingleChildScrollView(
              child: Container(
                height: height,
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StmsCard(
                      title1: 'Sale Invoice Doc No.',
                      subtitle1: '$siDoc',
                      title2: 'Date',
                      subtitle2: '$siDate',
                      title3: 'Customer Name',
                      subtitle3: '$customer',
                    ),
                    Container(
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
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
                                0: FixedColumnWidth(80.0),
                                1: FixedColumnWidth(45.0),
                                2: FixedColumnWidth(45.0),
                                3: FixedColumnWidth(45.0),
                                4: FixedColumnWidth(40.0),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      height: 35,
                                      child: Text(
                                        ' ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          // height: 1.8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      'SKU',
                                      style: TextStyle(fontSize: 14.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'SI Qty',
                                      style: TextStyle(fontSize: 14.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'ENT Qty',
                                      style: TextStyle(fontSize: 14.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Received Qty',
                                      style: TextStyle(fontSize: 14.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      ' ',
                                      style: TextStyle(fontSize: 14.0),
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
                                  // print(
                                  //     'snapshot: ${snapshot.data[0]['item_inventory_id']}');
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
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
                                            0: FixedColumnWidth(80.0),
                                            1: FixedColumnWidth(45.0),
                                            2: FixedColumnWidth(45.0),
                                            3: FixedColumnWidth(45.0),
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
                                                  TextStyle(fontSize: 14.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  "${snapshot.data[index]['item_quantity']}",
                                                  style:
                                                  TextStyle(fontSize: 14.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  "",
                                                  style:
                                                  TextStyle(fontSize: 14.0),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  "${snapshot.data[index]['item_receive_qty']}",
                                                  style:
                                                  TextStyle(fontSize: 14.0),
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

                                                          snapshot.data[index][
                                                          'tracking_type'] ==
                                                              "2"
                                                              ? serialList =
                                                          snapshot.data[
                                                          index][
                                                          'serial_list']
                                                              : serialList = [];

                                                          selectedItem = snapshot
                                                              .data[index][
                                                          'item_inventory_id'];
                                                          prefs.setString(
                                                              'selectedSiID',
                                                              selectedItem);

                                                          prefs.setString(
                                                              'siTracking',
                                                              snapshot.data[index]
                                                              [
                                                              'tracking_type']);
                                                          var tracking = snapshot
                                                              .data[index]
                                                          ['tracking_type'];
                                                          var typeScan = 'scan';
                                                          itemName =
                                                          snapshot.data[index]
                                                          ['item_name'];

                                                          tracking == "2"
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
                                                              await SharedPreferences
                                                                  .getInstance();

                                                              prefs.setString(
                                                                  'si_serialList',
                                                                  json.encode(
                                                                      snapshot.data[index]
                                                                      [
                                                                      'serial_list']));

                                                              selectedItem =
                                                              snapshot.data[
                                                              index]
                                                              [
                                                              'item_inventory_id'];
                                                              prefs.setString(
                                                                  'selectedSiID',
                                                                  selectedItem);

                                                              prefs.setString(
                                                                  'siTracking',
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
                                                              index]
                                                              [
                                                              'item_name'];

                                                              checkLocation(
                                                                  tracking,
                                                                  typeScan);
                                                            },
                                                            child: Text(
                                                              'MANUAL',
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                14.0,
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
                                                              viewBarcode(snapshot
                                                                  .data[
                                                              index]
                                                              [
                                                              'item_inventory_id']);
                                                            },
                                                            child: Text(
                                                              'VIEW',
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                14.0,
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
                                                      child: FittedBox(
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
                                                            await SharedPreferences
                                                                .getInstance();

                                                            snapshot.data[index]
                                                            [
                                                            'tracking_type'] ==
                                                                "2"
                                                                ? serialList =
                                                            snapshot.data[
                                                            index]
                                                            [
                                                            'serial_list']
                                                                : serialList =
                                                            [];

                                                            selectedItem =
                                                            snapshot.data[
                                                            index]
                                                            [
                                                            'item_inventory_id'];
                                                            prefs.setString(
                                                                'selectedSiID',
                                                                selectedItem);

                                                            prefs.setString(
                                                                'siTracking',
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
                                                            index]
                                                            ['item_name'];

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
                                                              fontSize: 14.0,
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                      )
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
            )
          );
        },
      ),
    );
  }

  Future checkLocation(String tracking, String typeScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var siLocation = prefs.getString('siLoc');
    print('siLoc: $siLocation');

    if (siLocation == null) {
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
            content: Container(
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
                                          var locId = locList.firstWhereOrNull(
                                              (element) =>
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
                                prefs.setString('siLoc', locationId);

                                Navigator.pop(context);

                                if (tracking == "2" && typeScan == 'scan') {
                                  scanBarcodeNormal();
                                } else if (tracking == "2" &&
                                    typeScan == 'manual') {
                                  Navigator.of(context)
                                      .pushNamed(StmsRoutes.siItemManual);
                                } else {
                                  prefs.setString('nontypeScan', typeScan);
                                  scanSKU();
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
          );
        },
      );
    } else {
      if (tracking == "2" && typeScan == 'scan') {
        scanBarcodeNormal();
      } else if (tracking == "2" && typeScan == 'manual') {
        Navigator.of(context).pushNamed(StmsRoutes.siItemManual);
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

    DBMasterInventoryHive().getAllInvHive().then((value) {
      siSkuListing = value;
      var itemSku = siSkuListing.firstWhereOrNull(
          (element) => element.sku == skuBarcode && element.sku == itemName);

      if (null == itemSku) {
        ErrorDialog.showErrorDialog(
            context, 'SKU not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');

        if (nonTrackingType == 'scan') {
          DBSaleInvoiceNonItem().getSiNonItem(selectedItem).then((value) {
            if (value == null) {
              DBSaleInvoiceNonItem()
                  .createSiNonItem(SaleInvoiceNon(
                itemInvId: selectedItem,
                nonTracking: '1',
              ))
                  .then((value) {
                showSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                  (element) => element['item_inventory_id'] == selectedItem);

              // print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty']) + 1;

              DBSaleInvoiceNonItem()
                  .update(selectedItem, newQty.toString())
                  .then((value) {
                showSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          Navigator.of(context).pushNamed(StmsRoutes.siItemDetail);
        }
      }
    });
  }

  searchUPC(String skuBarcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBMasterInventoryHive().getAllInvHive().then((value) {
      siSkuListing = value;

      var itemUpc = siSkuListing.firstWhereOrNull(
          (element) => element.upc == skuBarcode && element.sku == itemName);

      if (null == itemUpc) {
        ErrorDialog.showErrorDialog(
            context, 'UPC not match with master inventory');
      } else {
        var nonTrackingType = prefs.getString('nontypeScan');

        if (nonTrackingType == 'scan') {
          DBSaleInvoiceNonItem().getSiNonItem(selectedItem).then((value) {
            if (value == null) {
              DBSaleInvoiceNonItem()
                  .createSiNonItem(SaleInvoiceNon(
                itemInvId: selectedItem,
                nonTracking: '1',
              ))
                  .then((value) {
                showSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            } else {
              List nonItem = value;
              var getItem = nonItem.firstWhereOrNull(
                  (element) => element['item_inventory_id'] == selectedItem);

              // print('value non qty: ${getItem['non_tracking_qty'].toString()}');
              var newQty = int.parse(getItem['non_tracking_qty']) + 1;

              DBSaleInvoiceNonItem()
                  .update(selectedItem, newQty.toString())
                  .then((value) {
                showSuccess('Item Save');
                var _duration = Duration(seconds: 1);
                return Timer(_duration, scanSKU);
              });
            }
          });
        } else {
          Navigator.of(context).pushNamed(StmsRoutes.siItemDetail);
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

    // siSerialNo = getInfoSi['items'];
    var itemSerial =
        serialList.firstWhereOrNull((element) => element == barcodeScanRes);
    print('serialNo: $itemSerial');

    if (null == itemSerial) {
      ErrorDialog.showErrorDialog(context, 'Serial No. not match');
    } else {
      DBSaleInvoiceItem().getAllSiItem().then((value) {
        if (value != null) {
          siItemListing = value;
          // print('item Serial list: $value');

          var itemSi = siItemListing.firstWhereOrNull(
              (element) => element['item_serial_no'] == barcodeScanRes);
          if (null == itemSi) {
            prefs.setString("itemBarcode", barcodeScanRes);

            Navigator.of(context)
                .pushNamed(StmsRoutes.siItemDetail)
                .then((value) {
              setState(() {
                scanBarcodeNormal();
              });
            });
          } else {
            ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
          }
        } else {
          prefs.setString("itemBarcode", barcodeScanRes);

          // await Future.delayed(const Duration(seconds: 3));
          Navigator.of(context)
              .pushNamed(StmsRoutes.siItemDetail)
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
    DBSaleInvoiceItem().getBarcodeSiItem(invNo).then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(context, 'No Serial No have been scan');
      } else {
        var getList = DBSaleInvoiceItem().getBarcodeSiItem(invNo);
        var getDb = 'DBSaleInvoiceItem';
        ViewDialog.showViewDialog(context, getList, getDb);
      }
    });
  }

  Future<void> uploadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('siId: ${prefs.getString('siId_upload')}');

    DBSaleInvoiceItem().getUpload().then((value) {
      siSerial = value;
    });

    DBSaleInvoiceNonItem().getUpload().then((value) {
      // print('value non si: $value');
      siNonTrack = value;
      if (siSerial != null && siNonTrack != null) {
        combineUpdated = []
          ..addAll(siSerial)
          ..addAll(siNonTrack);
      } else if (siSerial == null) {
        combineUpdated = siNonTrack;
      } else {
        combineUpdated = siSerial;
      }

      SaleInvoiceService().sendToServer(combineUpdated).then((value) {
        if (value['status'] == true) {
          DBSaleInvoiceItem().deleteAllSiItem();
          DBSaleInvoiceNonItem().deleteAllSiNonItem();
          prefs.remove('si_info');
          prefs.remove('siLoc');

          Navigator.popUntil(context, ModalRoute.withName(StmsRoutes.siView));
          SuccessDialog.showSuccessDialog(context, value['message']);
        } else {
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });

    DBSaleInvoiceItem().getUpload().then((value) {
      print('value get: $value');
    });
  }
}
