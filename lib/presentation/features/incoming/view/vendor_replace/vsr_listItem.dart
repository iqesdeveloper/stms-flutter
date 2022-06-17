import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_vsr.dart';
import 'package:stms/data/api/repositories/api_json/api_out_rv.dart';
import 'package:stms/data/local_db/incoming/vsr/vsr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/vsr/vsr_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class VsrListItem extends StatefulWidget {
  const VsrListItem({Key? key}) : super(key: key);

  @override
  _VsrListItemState createState() => _VsrListItemState();
}

class _VsrListItemState extends State<VsrListItem> {
  // ignore: unused_field
  String _scanBarcode = 'Unknown';
  List inventoryList = [];
  List<InventoryHive> masterInvList = [];
  List vsrItemListing = [];
  // InventoryHive? invName;
  var invName,
      adjustInItem,
      selectedItem,
      vsrSerial,
      vsrNonTrack,
      combineUpdated,
      inventoryId;

  @override
  void initState() {
    super.initState();

    getVsrItem();
    getListItem();
    getCommon();

    fToast = FToast();
    fToast.init(context);
  }

  getVsrItem() {
    DBVendorReplaceItem().getAllVsrItem();
    DBVendorReplaceNonItem().getAllVsrNonItem();
  }

  getCommon() {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      } else {
        setState(() {
          masterInvList = value;
        });
      }
    });
  }

  Future<void> getListItem() async {
    ReturnVendorService().getRvItem().then((value) {
      setState(() {
        inventoryList = value;
        print('item RV list: $inventoryList');
      });
    });
  }

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
                            future: DBVendorReplaceItem().getAllVsrItem(),
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
                                    invName = inventoryList.firstWhereOrNull(
                                        (element) =>
                                            element['item_inventory_id'] ==
                                            snapshot.data[index]
                                                ['item_inventory_id']);
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
                                                  "${invName['item_name']}",
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
                            future: DBVendorReplaceNonItem().getAllVsrNonItem(),
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
                                    invName = inventoryList.firstWhereOrNull(
                                        (element) =>
                                            element['item_inventory_id'] ==
                                            snapshot.data[index]
                                                ['item_inventory_id']);
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
                                                  "${invName['item_name']}",
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
                                              Text(
                                                "${snapshot.data[index]['non_tracking_qty']}",
                                                style:
                                                TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
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
                              addItem();
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
    print('inv id: $itemInvId');
    if (type == 'serial') {
      DBVendorReplaceItem()
          .deleteVsrItem(itemInvId, itemSerialNo)
          .then((value) {
        if (value == 1) {
          setState(() {
            getVsrItem();
            showSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else {
      DBVendorReplaceNonItem().deleteVsrNonItem(itemInvId).then((value) {
        if (value == 1) {
          setState(() {
            getVsrItem();
            showSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    }
  }

  Future uploadVendorReplace() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    DBVendorReplaceItem().getUpload().then((value) {
      // print('value serial po: $value');
      vsrSerial = value;
    });

    DBVendorReplaceNonItem().getUpload().then((value) {
      // print('value non Po: $value');
      vsrNonTrack = value;
      if (vsrSerial != null && vsrNonTrack != null) {
        combineUpdated = []
          ..addAll(vsrSerial)
          ..addAll(vsrNonTrack);
      } else if (vsrSerial == null) {
        combineUpdated = vsrNonTrack;
      } else {
        combineUpdated = vsrSerial;
      }

      // print('combine update: $combineUpdated');

      VendorReplaceService().sendToServer(combineUpdated).then((value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (value['status'] == true) {
          DBVendorReplaceItem().deleteAllVsrItem();
          DBVendorReplaceNonItem().deleteAllVsrNonItem();
          prefs.remove('saveVSR');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.replaceSupplier));
          SuccessDialog.showSuccessDialog(context,
              "Vendor Replacement created successfully"); //value['message']
        } else {
          ErrorDialog.showErrorDialog(context, value['message']);
        }
      });
    });
  }

  Future addItem() async {
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
                                    items: inventoryList.map((item) {
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
                                // prefs.setString('vsrItem', selectedItem);

                                findInv(selectedItem);
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
  Future<void> findInv(var selectedItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjust = masterInvList.firstWhereOrNull(
        (element) => element.id == selectedItem);

    prefs.setString('vsrTracking', itemAdjust!.type);
    prefs.setString('vsrItem', itemAdjust.sku);

    if (itemAdjust.type == '2') {
      var typeScan = 'invId';
      scanBarcodeNormal(typeScan);
    } else {
      // prefs.setString('itemQty', itemAdjust['item_quantity']);

      Navigator.of(context)
          .pushNamed(StmsRoutes.vsrItemCreate)
          .whenComplete(() {
        setState(() {
          getVsrItem();
          selectedItem = null;
        });
      });
    }
    // if (itemAdjust == null) {
    //   ErrorDialog.showErrorDialog(context, "No SKU match!");
    // } else {
    //   if (itemAdjust.type == '2') {
    //     var typeScan = 'invId';
    //     scanBarcodeNormal(typeScan);
    //   } else {
    //    // prefs.setString('itemQty', itemAdjust['item_quantity']);
    //
    //     Navigator.of(context)
    //         .pushNamed(StmsRoutes.vsrItemCreate)
    //         .whenComplete(() {
    //       setState(() {
    //         getVsrItem();
    //         selectedItem = null;
    //       });
    //     });
    //   }
    // }
  }

  Future<void> scanBarcodeNormal(String typeScan) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', '', true, ScanMode.BARCODE);
      print('barcodeScanRes: $barcodeScanRes');
      if (barcodeScanRes != '-1') {
        print('barcode: $barcodeScanRes');
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
    var selectedId = prefs.getString('vsrItem');

    var itemAdjust = inventoryList.firstWhereOrNull(
        (element) => element['item_inventory_id'] == selectedId);

    if (itemAdjust != null) {
      List currentSerial = itemAdjust['serial_list'];
      var serialList =
          currentSerial.firstWhereOrNull((e) => e == barcodeScanRes);

      if (serialList != null) {
        DBVendorReplaceItem().getAllVsrItem().then((value) {
          // ignore: unnecessary_null_comparison
          if (value != null) {
            vsrItemListing = value;
            // print('item Serial list: $value');

            var itemVsr = vsrItemListing.firstWhereOrNull(
                (element) => element['item_serial_no'] == barcodeScanRes);
            if (null == itemVsr) {
              prefs.setString("itemBarcode", barcodeScanRes);

              Navigator.of(context)
                  .pushNamed(StmsRoutes.vsrItemCreate)
                  .whenComplete(() {
                setState(() {
                  var typeScan = 'invId';
                  getVsrItem();
                  selectedItem = null;
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
                .pushNamed(StmsRoutes.vsrItemCreate)
                .whenComplete(() {
              setState(() {
                var typeScan = 'invId';
                getVsrItem();
                selectedItem = null;
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

  Future<void> searchSku(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjust = inventoryList.firstWhereOrNull((element) =>
        element['item_name'] == skuScan); // || element['upc'] == skuScan

    if (itemAdjust == null) {
      ErrorDialog.showErrorDialog(context, "No SKU match!");
    } else {
      prefs.setString('vsrTracking', itemAdjust['tracking_type']);
      prefs.setString('vsrItem', itemAdjust['item_name']);

      if (itemAdjust['tracking_type'] == '2') {
        scanItemSerial();
      } else {
        // prefs.setString('itemQty', itemAdjust['item_quantity']);

        Navigator.of(context)
            .pushNamed(StmsRoutes.vsrItemCreate)
            .whenComplete(() {
          setState(() {
            getVsrItem();
            selectedItem = null;
          });
        });
      }
    }
  }

  Future<void> searchUPC(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemUpc =
        masterInvList.firstWhereOrNull((element) => element.upc == skuScan);
    // print('itemUpc: ${itemUpc!.name}');

    if (itemUpc != null) {
      prefs.setString('vsrTracking', itemUpc.type);
      prefs.setString('vsrItem', itemUpc.sku);

      if (itemUpc.type == '2') {
        scanItemSerial();
      } else {
        // prefs.setString('itemQty', itemSku['item_quantity']);

        Navigator.of(context)
            .pushNamed(StmsRoutes.vsrItemCreate)
            .whenComplete(() {
          setState(() {
            getVsrItem();
            selectedItem = null;
          });
        });
      }
    } else {
      ErrorDialog.showErrorDialog(context, "No UPC match!");
    }


    // var itemSku = inventoryList
    //     .firstWhereOrNull((element) => element['item_name'] == itemUpc!.sku);
    //
    // if (itemUpc != null && itemSku != null) {
    //   prefs.setString('vsrTracking', itemSku['tracking_type']);
    //   prefs.setString('vsrItem', itemSku['item_serial_no']);
    //
    //   if (itemSku['tracking_type'] == '2') {
    //     scanItemSerial();
    //   } else {
    //     prefs.setString('itemQty', itemSku['item_quantity']);
    //
    //     Navigator.of(context)
    //         .pushNamed(StmsRoutes.vsrItemCreate)
    //         .whenComplete(() {
    //       setState(() {
    //         getVsrItem();
    //         selectedItem = null;
    //       });
    //     });
    //   }
    // } else {
    //   ErrorDialog.showErrorDialog(context, "No UPC match!");
    // }
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
