import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_custReturn.dart';
import 'package:stms/data/local_db/incoming/cr/cr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/cr/cr_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class CrListItem extends StatefulWidget {
  const CrListItem({Key? key}) : super(key: key);

  @override
  _CrListItemState createState() => _CrListItemState();
}

class _CrListItemState extends State<CrListItem> {
  // ignore: unused_field
  String _scanBarcode = 'Unknown';
  List<InventoryHive> inventoryList = [];
  List crItemListing = [];
  InventoryHive? invName;
  var custRetItem,
      selectedItem,
      crSerial,
      crNonTrack,
      combineUpdated,
      inventoryId;

  @override
  void initState() {
    super.initState();

    getCrItem();
    getCommon();
  }

  getCrItem() {
    DBCustReturnItem().getAllCrItem();
    DBCustReturnNonItem().getAllCrNonItem();
  }

  getCommon() {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      } else {
        setState(() {
          inventoryList = value;
        });
      }
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
                              0: FixedColumnWidth(120.0),
                              1: FixedColumnWidth(33.0),
                              3: FixedColumnWidth(50.0),
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
                                    'Qty',
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Serial Number',
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
                            future: DBCustReturnItem().getAllCrItem(),
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
                                            element.id ==
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
                                          0: FixedColumnWidth(120.0),
                                          1: FixedColumnWidth(33.0),
                                          3: FixedColumnWidth(50.0),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Container(
                                                height: 35,
                                                child: Text(
                                                  "${invName!.sku}",
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
                                                "1",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "${snapshot.data[index]['item_serial_no']}",
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
                            future: DBCustReturnNonItem().getAllCrNonItem(),
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
                                            element.id ==
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
                                          0: FixedColumnWidth(120.0),
                                          1: FixedColumnWidth(33.0),
                                          3: FixedColumnWidth(50.0),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Container(
                                                height: 35,
                                                child: Text(
                                                  "${invName!.sku}",
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
                                                "${snapshot.data[index]['non_tracking_qty']}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "-",
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
                              uploadCustRet();
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
      DBCustReturnItem().deleteCrItem(itemInvId, itemSerialNo).then((value) {
        if (value == 1) {
          setState(() {
            getCrItem();
            showSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else {
      DBCustReturnNonItem().deleteCrNonItem(itemInvId).then((value) {
        if (value == 1) {
          setState(() {
            getCrItem();
            showSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    }
  }

  Future uploadCustRet() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    DBCustReturnItem().getUpload().then((value) {
      crSerial = value;
    });

    DBCustReturnNonItem().getUpload().then((value) {
      crNonTrack = value;
      if (crSerial != null && crNonTrack != null) {
        combineUpdated = []
          ..addAll(crSerial)
          ..addAll(crNonTrack);
      } else if (crSerial == null) {
        combineUpdated = crNonTrack;
      } else {
        combineUpdated = crSerial;
      }

      CustReturnService().sendToServer(combineUpdated).then((value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (value['status'] == true) {
          DBCustReturnItem().deleteAllCrItem();
          DBCustReturnNonItem().deleteAllCrNonItem();
          prefs.remove('saveCr');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.returnCustomer));
          SuccessDialog.showSuccessDialog(context, value['message']);
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
          content: SingleChildScrollView(
            child: Container(
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
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return SearchChoices.single(
                                  padding: 10,
                                  displayClearIcon: false,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                  // iconEnabledColor: Colors.amberAccent,
                                  iconDisabledColor: Colors.grey[350],
                                  items: inventoryList.map((item) {
                                    return new DropdownMenuItem(
                                      child: Text(
                                        item.sku,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      value: item.sku,
                                    );
                                  }).toList(),
                                  value: selectedItem,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedItem = value;
                                      var invId = inventoryList
                                          .firstWhereOrNull((element) =>
                                              element.sku == value);
                                      inventoryId = invId!.id;
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
                                    var typeScan = 'sku';
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
                                  prefs.setString('crItem', inventoryId);

                                  findInv(inventoryId);
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
          ),
        );
      },
    );
  }

  /// Find a person in the list using firstWhere method.
  Future<void> findInv(String selectedItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemCustRet =
        inventoryList.firstWhereOrNull((element) => element.id == selectedItem);

    prefs.setString('crTracking', itemCustRet!.type);

    if (itemCustRet.type == 'Serial Number') {
      var typeScan = 'invId';
      scanBarcodeNormal(typeScan);
    } else {
      Navigator.of(context).pushNamed(StmsRoutes.crItemCreate).whenComplete(() {
        setState(() {
          getCrItem();
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
        } else {
          searchSku(barcodeScanRes);
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

    DBCustReturnItem().getAllCrItem().then((value) {
      if (value != null) {
        crItemListing = value;

        var itemCr = crItemListing.firstWhereOrNull(
            (element) => element['item_serial_no'] == barcodeScanRes);
        if (null == itemCr) {
          prefs.setString("itemBarcode", barcodeScanRes);

          Navigator.of(context)
              .pushNamed(StmsRoutes.crItemCreate)
              .whenComplete(() {
            setState(() {
              var typeScan = 'invId';
              getCrItem();
              scanBarcodeNormal(typeScan);
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
            .pushNamed(StmsRoutes.crItemCreate)
            .whenComplete(() {
          setState(() {
            var typeScan = 'invId';
            getCrItem();
            scanBarcodeNormal(typeScan);
          });
        });
      }
    });
  }

  Future<void> searchSku(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemCustRet = inventoryList.firstWhereOrNull(
        (element) => element.sku == skuScan || element.upc == skuScan);

    if (null == itemCustRet) {
      ErrorDialog.showErrorDialog(
          context, 'SKU not match with master inventory');
    } else {
      prefs.setString('crTracking', itemCustRet.type);
      prefs.setString('crItem', itemCustRet.id);

      if (itemCustRet.type == 'Serial Number') {
        scanItemSerial();
      } else {
        Navigator.of(context)
            .pushNamed(StmsRoutes.crItemCreate)
            .whenComplete(() {
          setState(() {
            getCrItem();
          });
        });
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
