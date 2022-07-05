import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_custReturn.dart';
import 'package:stms/data/api/repositories/api_json/api_in_vsr.dart';
import 'package:stms/data/api/repositories/api_json/api_out_rric.dart';
import 'package:stms/data/api/repositories/api_json/api_out_rv.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/outgoing/rric/rric_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/rric/rric_scanItem.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class RcListItem extends StatefulWidget {
  const RcListItem({Key? key}) : super(key: key);

  @override
  _RcListItemState createState() => _RcListItemState();
}

class _RcListItemState extends State<RcListItem> {
  // ignore: unused_field
  String _scanBarcode = 'Unknown';
  List<InventoryHive> masterInventoryList = [];
  List inventoryList = [];
  List inventoryCRList = [];
  List inventoryRvList = [];
  List rcItemListing = [];
  List reasonList = [];
  List repairList = [];
  List allRcItem = [];
  List allRcNonItem = [];
  late InventoryHive invName;
  var invSerial,
      reasonName,
      adjustInItem,
      selectedItem,
      rcSerial,
      rcNonTrack,
      combineUpdated,
      transType;

  @override
  void initState() {
    super.initState();

    getRcItem();
    getListItem();
    getCrListItem();
    transactionType();
    getCommon();
    getEnterQty();
  }

  getRcItem() {
    DBReplaceCustItem().getAllRricItem();
    DBReplaceCustNonItem().getAllRricNonItem();
  }

  Future<void> getListItem() async {
    VendorReplaceService().getVsrItem().then((value) {
      setState(() {
        inventoryList = value;
      });
    });
  }

  Future<void> getCrListItem() async {
    CustReturnService().getCrItem().then((value) {
      setState(() {
        inventoryCRList = value;
        getRvListItem();
      });
    });
  }

  Future<void> getRvListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = Storage().token;
    var txnNo = prefs.getString('crTxnNo');

    ReturnVendorService().getRvList(token).then((value) {
      setState(() {
        inventoryRvList = value;

        var rvTxnNo = inventoryRvList
            .firstWhereOrNull((element) => element['out_rs_doc'] == txnNo);

        if (rvTxnNo == null) {
          repairList = inventoryCRList;
        } else {
          prefs.setString('selectedRv', rvTxnNo['out_rs_id']);

          ReturnVendorService().getRvItem().then((value) {
            var rvItem = value;

            repairList = inventoryCRList
                .where(
                    (element) => !rvItem.contains(element['item_inventory_id']))
                .toList();
          });
        }
      });
    });
  }

  transactionType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getdata = prefs.getString('saveRRIC');
    var rricData = json.decode(getdata!) as Map<String, dynamic>;

    transType = rricData['transaction_type'];
  }

  getCommon() {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      } else {
        setState(() {
          masterInventoryList = value;
        });
      }
    });
  }

  // Check and get all Item and Non Item in DB
  getEnterQty() {
    DBReplaceCustItem().getAllRricItem().then((value) {
      setState(() {
        allRcItem = value;
        // print('after save: $allPoNonItem');
      });
    });

    DBReplaceCustNonItem().getAllRricNonItem().then((value) {
      setState(() {
        allRcNonItem = value;
        // print('after save: $allPoItem');
      });
    });
  }

  // DBMasterReason().getAllMasterReason().then((value) {
  //   // print('value loc: $value');
  //   if (value == null) {
  //     ErrorDialog.showErrorDialog(
  //         context, 'Please download reason code file at master page first');
  //   } else {
  //     setState(() {
  //       reasonList = value;
  //     });
  //   }
  // });
  // }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;

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
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    height: height * 0.65,
                    child: ListView(
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
                              0: FixedColumnWidth(100.0),
                              1: FixedColumnWidth(60.0),
                              2: FixedColumnWidth(30.0),
                              3: FixedColumnWidth(40.0),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Container(
                                    height: 35,
                                    child: Text(
                                      'SKU',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        height: 1.8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    'Serial Number',
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Ent Qty',
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
                        SizedBox(height: 2),
                        Container(
                          // padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: FutureBuilder(
                            future: DBReplaceCustItem().getAllRricItem(),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot snapshot,
                            ) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: Container(),
                                );
                              } else {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    invName = masterInventoryList
                                        .firstWhereOrNull((element) =>
                                            element.id ==
                                            snapshot.data[index]
                                                ['item_inventory_id'])!;
                                    // print('invName: ${invName.name}');
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
                                          0: FixedColumnWidth(100.0),
                                          1: FixedColumnWidth(60.0),
                                          2: FixedColumnWidth(30.0),
                                          3: FixedColumnWidth(40.0),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Container(
                                                height: 35,
                                                child: Text(
                                                  "${invName.name}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    height: 1.8,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Text(
                                                "${snapshot.data[index]['item_serial_no']}",
                                                style:
                                                TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "1",
                                                style:
                                                TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0),
                                                  onPressed: () {
                                                    var type = 'serial';
                                                    getDB(
                                                        snapshot.data[index][
                                                            'item_inventory_id'],
                                                        type,
                                                        snapshot.data[index]
                                                            ['item_serial_no']);
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
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
                        Container(
                          child: FutureBuilder(
                            future: DBReplaceCustNonItem().getAllRricNonItem(),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot snapshot,
                            ) {
                              if (!snapshot.hasData) {
                                return Center(
                                  // child: CircularProgressIndicator(),
                                  child: Container(),
                                );
                              } else {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    invSerial = transType == '1'
                                        ? inventoryList.firstWhereOrNull(
                                            (element) =>
                                                element['item_inventory_id'] ==
                                                snapshot.data[index]
                                                    ['item_inventory_id'])
                                        : repairList.firstWhereOrNull(
                                            (element) =>
                                                element['item_inventory_id'] ==
                                                snapshot.data[index]
                                                    ['item_inventory_id']);
                                    // print('invSerial: $invSerial');
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
                                          0: FixedColumnWidth(100.0),
                                          1: FixedColumnWidth(60.0),
                                          2: FixedColumnWidth(30.0),
                                          3: FixedColumnWidth(40.0),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Container(
                                                height: 35,
                                                child: Text(
                                                  "${invSerial['item_name']}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    height: 1.8,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Text(
                                                "-",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              // Enter Quantity
                                              snapshot.data[index]['tracking_type'] == '2' ?
                                              Text(
                                                // CHECK ALL ITEM GOT VALUE OR NOT
                                                allRcItem.isNotEmpty ?
                                                allRcItem.where((element) => element['item_inventory_id'] ==
                                                    snapshot.data[index]['item_inventory_id']).isNotEmpty ?
                                                // IF NOT EMPTY, DISPLAY TOTAL SAME ID IN DB
                                                '${allRcItem.where((element) => element['item_inventory_id'] ==
                                                    snapshot.data[index]['item_inventory_id']).length}'
                                                // ELSE, DISPLAY 0
                                                    : '0'
                                                // IF NO VALUE DISPLAY 0
                                                    : '0',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16.0
                                                ),
                                              ) :
                                              Text(
                                                // CHECK ALL ITEM GOT VALUE OR NOT
                                                allRcNonItem.isNotEmpty ?
                                                allRcNonItem.firstWhereOrNull((element) => element['item_inventory_id'] ==
                                                    snapshot.data[index]['item_inventory_id']) != null ?
                                                // IF NOT EMPTY, DISPLAY TOTAL SAME ID IN DB
                                                "${allRcNonItem.firstWhereOrNull((element) => element['item_inventory_id'] ==
                                                    snapshot.data[index]['item_inventory_id'])['non_tracking_qty']}"
                                                // ELSE, DISPLAY 0
                                                    : '0'
                                                // IF NO VALUE DISPLAY 0
                                                    : '0',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16.0
                                                ),
                                              ),
                                              // Text(
                                              //   "${snapshot.data[index]['non_tracking_qty']}",
                                              //   style:
                                              //   TextStyle(fontSize: 16.0),
                                              //   textAlign: TextAlign.center,
                                              // ),
                                              Container(
                                                alignment: Alignment.center,
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0),
                                                  onPressed: () {
                                                    var type = 'nonTracking';
                                                    getDB(
                                                        snapshot.data[index][
                                                            'item_inventory_id'],
                                                        type,
                                                        '-');
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
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
                      height: height * 0.02,
                      // color: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          StmsStyleButton(
                            title: 'ADD ITEM',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () {
                              if (transType == '1') {
                                addItem(inventoryList);
                              } else {
                                addItem(repairList);
                              }
                            },
                          ),
                          StmsStyleButton(
                            title: 'UPLOAD',
                            backgroundColor: Colors.blueAccent,
                            textColor: Colors.white,
                            onPressed: () {
                              uploadVendorReplace();
                            },
                          ),
                        ],
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

  getDB(String itemInvId, String type, String itemSerialNo) {
    if (type == 'serial') {
      DBReplaceCustItem().deleteRricItem(itemInvId, itemSerialNo).then((value) {
        if (value == 1) {
          setState(() {
            fToast.init(context);
            getRcItem();
            showCustomSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else {
      DBReplaceCustNonItem().deleteRricNonItem(itemInvId).then((value) {
        if (value == 1) {
          setState(() {
            fToast.init(context);
            getRcItem();
            showCustomSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    }
  }

  Future uploadVendorReplace() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBReplaceCustItem().getUpload().then((value) {
      rcSerial = value;
    });

    DBReplaceCustNonItem().getUpload().then((value) {
      rcNonTrack = value;
      if (rcSerial != null && rcNonTrack != null) {
        combineUpdated = []
          ..addAll(rcSerial)
          ..addAll(rcNonTrack);
      } else if (rcSerial == null) {
        combineUpdated = rcNonTrack;
      } else {
        combineUpdated = rcSerial;
      }

      ReplaceCustService().sendToServer(combineUpdated).then((value) {
        if (value['status'] == true) {
          DBReplaceCustItem().deleteAllRricItem();
          DBReplaceCustNonItem().deleteAllRricNonItem();
          prefs.remove('saveRRIC');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.repairCustomer));
          SuccessDialog.showSuccessDialog(context,
              "Customer replacement created successfully."); //value['message']
        } else {
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });
  }

  Future addItem(List newListItem) async {
    return showDialog(
      context: context,
      builder: (context) {
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;

        return AlertDialog(
          // insetPadding: EdgeInsets.all(15),
          contentPadding: EdgeInsets.all(10.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: Container(
            height: height * 0.6,
            width: width,
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.42,
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return Container(
                        // padding: EdgeInsets.symmetric(horizontal: 5),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Add Item',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    iconSize: 28,
                                    iconEnabledColor: Colors.amber,
                                    items: newListItem.map((item) {
                                      return new DropdownMenuItem(
                                        child: Text(
                                          item['item_name'],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        value: item['item_inventory_id']
                                            .toString(),
                                      );
                                    }).toList(),
                                    isExpanded: true,
                                    value:
                                        selectedItem == "" ? "" : selectedItem,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedItem = newValue;
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
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: height * 0.02,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ButtonTheme(
                              minWidth: width * 0.4,
                              height: 50,
                              child: StmsStyleButton(
                                title: 'SCAN SKU',
                                width: width * 0.35,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                onPressed: () {
                                  var typeScan = 'sku';
                                  scanBarcodeNormal(typeScan);
                                },
                              ),
                            ),
                            ButtonTheme(
                              minWidth: width * 0.4,
                              height: 50,
                              child: StmsStyleButton(
                                title: 'SCAN UPC',
                                width: width * 0.35,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                onPressed: () {
                                  var typeScan = 'upc';
                                  scanBarcodeNormal(typeScan);
                                },
                              ),
                            ),
                          ],
                        ),
                        ButtonTheme(
                          minWidth: 200,
                          height: 50,
                          child: StmsStyleButton(
                            title: 'SELECT',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () async {
                              if (selectedItem == null) {
                                ErrorDialog.showErrorDialog(
                                    context, 'Please add an item');
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                // prefs.setString('rcItem', selectedItem);

                                findInv(selectedItem, newListItem);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// Find a person in the list using firstWhere method.
  Future<void> findInv(String selectedItem, List newListItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjust = newListItem.firstWhereOrNull(
        (element) => element['item_inventory_id'] == selectedItem);

    prefs.setString('rcTracking', itemAdjust['tracking_type']);
    prefs.setString('rcItem', itemAdjust['item_name']);

    if (itemAdjust['tracking_type'] == '2') {
      var typeScan = 'invId';
      scanBarcodeNormal(typeScan);
    } else {
      prefs.setString('itemQty', itemAdjust['item_quantity']);

      Navigator.of(context).pushNamed(StmsRoutes.rcItemCreate).whenComplete(() {
        setState(() {
          getEnterQty();
          getRcItem();
        });
      });
    }
  }

  Future<void> scanBarcodeNormal(String typeScan) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);

      if (barcodeScanRes != '-1') {
        if (typeScan == 'invId') {
          saveData(barcodeScanRes);
        } else if (typeScan == 'sku') {
          searchSku(barcodeScanRes);
        } else {
          searchUPC(barcodeScanRes);
        }

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
    var selectedId = prefs.getString('rcItem');

    var itemAdjust = transType == '1'
        ? inventoryList.firstWhereOrNull(
            (element) => element['item_inventory_id'] == selectedId)
        : repairList.firstWhereOrNull(
            (element) => element['item_inventory_id'] == selectedId);

    if (itemAdjust != null) {
      List currentSerial = itemAdjust['serial_list'];

      var serialList =
          currentSerial.firstWhereOrNull((e) => e == barcodeScanRes);
      // print('serialList: $serialList');
      if (serialList != null) {
        DBReplaceCustItem().getAllRricItem().then((value) {
          // ignore: unnecessary_null_comparison
          if (value != null) {
            rcItemListing = value;

            var itemRc = rcItemListing.firstWhereOrNull(
                (element) => element['item_serial_no'] == barcodeScanRes);
            if (null == itemRc) {
              prefs.setString("itemBarcode", barcodeScanRes);

              Navigator.of(context)
                  .pushNamed(StmsRoutes.rcItemCreate)
                  .whenComplete(() {
                setState(() {
                  var typeScan = 'invId';
                  getEnterQty();
                  getRcItem();
                  // scanBarcodeNormal(typeScan);
                });
              });
            } else {
              ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
            }
          } else {
            // prefs.setString("itemSelect", json.encode(item));
            prefs.setString("itemBarcode", barcodeScanRes);

            // await Future.delayed(const Duration(seconds: 3));
            Navigator.of(context)
                .pushNamed(StmsRoutes.rcItemCreate)
                .whenComplete(() {
              setState(() {
                var typeScan = 'invId';
                getEnterQty();
                getRcItem();
                // scanBarcodeNormal(typeScan);
              });
            });
          }
        });
      } else {
        ErrorDialog.showErrorDialog(
            context, 'Serial No not match with document.');
      }
    }
  }

  // - SCAN
  // - CHECK SCAN USING SKU OR UPC
  // - IF SKU, CHECK USING INVLIST OR REPAIRLIST
  // - IF UPC, CHECK USING MASTERLIST AND COMPARE WITH ABOVE

  Future<void> searchSku(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjust = transType == '1'
        ? inventoryList
            .firstWhereOrNull((element) => element['item_name'] == skuScan)
        : repairList
            .firstWhereOrNull((element) => element['item_name'] == skuScan);

    if (itemAdjust == null) {
      ErrorDialog.showErrorDialog(context, "No SKU match!");
    } else {
      prefs.setString('rcTracking', itemAdjust['tracking_type']);
      prefs.setString('rcItem', itemAdjust['item_name']);

      if (itemAdjust['tracking_type'] == '2') {
        print('inventory id: ${itemAdjust['item_inventory_id']}');
        scanItemSerial();
      } else {
        prefs.setString('itemQty', itemAdjust['item_quantity']);
        Navigator.of(context)
            .pushNamed(StmsRoutes.rcItemCreate)
            .whenComplete(() {
          setState(() {
            getEnterQty();
            getRcItem();
          });
        });
      }
    }
  }

  Future<void> searchUPC(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjustUpc = masterInventoryList
        .firstWhereOrNull((element) => element.upc == skuScan);
    print('itemadjustUpc: $itemAdjustUpc');

    if (itemAdjustUpc == null) {
      ErrorDialog.showErrorDialog(context, "No UPC match!");
    } else {
      var itemAdjust = transType == '1'
          ? inventoryList.firstWhereOrNull(
              (element) => element['item_name'] == itemAdjustUpc.sku)
          : repairList.firstWhereOrNull(
              (element) => element['item_name'] == itemAdjustUpc.sku);

      if (itemAdjust != null) {
        prefs.setString('rcTracking', itemAdjust['tracking_type']);
        prefs.setString('rcItem', itemAdjust['item_name']);

        if (itemAdjust['tracking_type'] == '2') {
          print('inventory id: ${itemAdjust['item_inventory_id']}');
          scanItemSerial();
        } else {
          prefs.setString('itemQty', itemAdjust['item_quantity']);
          Navigator.of(context)
              .pushNamed(StmsRoutes.rcItemCreate)
              .whenComplete(() {
            setState(() {
              getEnterQty();
              getRcItem();
            });
          });
        }
      }
    }
  }

  Future scanItemSerial() async {
    return showDialog(
      context: context,
      builder: (context) {
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;

        return AlertDialog(
          // insetPadding: EdgeInsets.all(15),
          contentPadding: EdgeInsets.all(10.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: Container(
            color: Colors.white,
            alignment: Alignment.center,
            height: height * 0.18,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: width,
                  height: height * 0.05,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Scan Serial Number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(thickness: 2),
                Expanded(
                    child: Container(
                  alignment: Alignment.center,
                  // color: Colors.blue,
                  child: ButtonTheme(
                    minWidth: 200,
                    height: 50,
                    child: StmsStyleButton(
                      title: 'SCAN SERIAL NO',
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      onPressed: () {
                        var typeScan = 'invId';
                        scanBarcodeNormal(typeScan);
                      },
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
