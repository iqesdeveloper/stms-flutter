import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_in_itemModify.dart';
import 'package:stms/data/local_db/incoming/im/im_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/im/im_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/success_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class ImListItem extends StatefulWidget {
  const ImListItem({Key? key}) : super(key: key);

  @override
  _ImListItemState createState() => _ImListItemState();
}

class _ImListItemState extends State<ImListItem> {
  // ignore: unused_field
  String _scanBarcode = 'Unknown';
  List<InventoryHive> inventoryList = [];
  List imItemListing = [];
  List reasonList = [];
  InventoryHive? invName;

  var reasonName,
      modifyItem,
      selectedItem,
      imSerial,
      imNonTrack,
      combineUpdated,
      inventoryId;

  @override
  void initState() {
    super.initState();

    getModifyItem();
    getCommon();
  }

  getModifyItem() {
    DBItemModifyItem().getAllImItem();
    DBItemModifyNonItem().getAllImNonItem();
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

    DBMasterReason().getAllMasterReason().then((value) {
      // print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download reason code file at master page first');
      } else {
        setState(() {
          reasonList = value;
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
                                    'Item Reason Code',
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
                            future: DBItemModifyItem().getAllImItem(),
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
                                    reasonName = reasonList.firstWhereOrNull(
                                        (element) =>
                                            element['id'] ==
                                            snapshot.data[index]
                                                ['item_reason_code']);
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
                                                "${reasonName['code']}",
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
                            future: DBItemModifyNonItem().getAllImNonItem(),
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
                                    reasonName = reasonList.firstWhereOrNull(
                                        (element) =>
                                            element['id'] ==
                                            snapshot.data[index]
                                                ['item_reason_code']);
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
                                                "${reasonName['code']}",
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
                              uploadItemModify();
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
      DBItemModifyItem().deleteImItem(itemInvId, itemSerialNo).then((value) {
        if (value == 1) {
          setState(() {
            getModifyItem();
            showSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else {
      DBItemModifyNonItem().deleteImNonItem(itemInvId).then((value) {
        if (value == 1) {
          setState(() {
            getModifyItem();
            showSuccess('Delete Successful');
          });
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    }
  }

  Future uploadItemModify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBItemModifyItem().getUpload().then((value) {
      // print('value serial po: $value');
      imSerial = value;
    });

    DBItemModifyNonItem().getUpload().then((value) {
      // print('value non Po: $value');
      imNonTrack = value;
      if (imSerial != null && imNonTrack != null) {
        combineUpdated = []
          ..addAll(imSerial)
          ..addAll(imNonTrack);
      } else if (imSerial == null) {
        combineUpdated = imNonTrack;
      } else {
        combineUpdated = imSerial;
      }

      ItemModifyService().sendToServer(combineUpdated).then((value) {
        if (value['status'] == true) {
          DBItemModifyItem().deleteAllImItem();
          DBItemModifyNonItem().deleteAllImNonItem();
          prefs.remove('saveIM');
          // prefs.remove('aiId_info');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.itemModify));
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
                                  prefs.setString('imItem', inventoryId);

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

    var itemModify =
        inventoryList.firstWhereOrNull((element) => element.id == selectedItem);

    prefs.setString('imTracking', itemModify!.type);

    if (itemModify.type == 'Serial Number') {
      var typeScan = 'invId';
      scanBarcodeNormal(typeScan);
    } else {
      Navigator.of(context).pushNamed(StmsRoutes.imItemCreate).whenComplete(() {
        setState(() {
          getModifyItem();
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

    DBItemModifyItem().getAllImItem().then((value) {
      if (value != null) {
        imItemListing = value;
        // print('item Serial list: $value');

        var itemIm = imItemListing.firstWhereOrNull(
            (element) => element['item_serial_no'] == barcodeScanRes);
        if (null == itemIm) {
          prefs.setString("itemBarcode", barcodeScanRes);

          Navigator.of(context)
              .pushNamed(StmsRoutes.imItemCreate)
              .whenComplete(() {
            setState(() {
              var typeScan = 'invId';
              getModifyItem();
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
            .pushNamed(StmsRoutes.imItemCreate)
            .whenComplete(() {
          setState(() {
            var typeScan = 'invId';
            getModifyItem();
            scanBarcodeNormal(typeScan);
          });
        });
      }
    });
  }

  Future<void> searchSku(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjust =
        inventoryList.firstWhereOrNull((element) => element.sku == skuScan);

    if (null == itemAdjust) {
      ErrorDialog.showErrorDialog(
          context, 'SKU not match with master inventory');
    } else {
      prefs.setString('imTracking', itemAdjust.type);
      prefs.setString('imItem', itemAdjust.id);

      if (itemAdjust.type == 'Serial Number') {
        scanItemSerial();
      } else {
        Navigator.of(context)
            .pushNamed(StmsRoutes.imItemCreate)
            .whenComplete(() {
          setState(() {
            getModifyItem();
          });
        });
      }
    }
  }

  Future<void> searchUPC(String skuScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var itemAdjust =
        inventoryList.firstWhereOrNull((element) => element.upc == skuScan);

    if (null == itemAdjust) {
      ErrorDialog.showErrorDialog(
          context, 'UPC not match with master inventory');
    } else {
      prefs.setString('imTracking', itemAdjust.type);
      prefs.setString('imItem', itemAdjust.id);

      if (itemAdjust.type == 'Serial Number') {
        scanItemSerial();
      } else {
        Navigator.of(context)
            .pushNamed(StmsRoutes.imItemCreate)
            .whenComplete(() {
          setState(() {
            getModifyItem();
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
