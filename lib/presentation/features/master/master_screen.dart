import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_common.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({Key? key}) : super(key: key);

  @override
  _MasterScreenState createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  bool _custDisable = false,
      _locDisable = false,
      _supDisable = false,
      _invDisable = false,
      _reasonDisable = false,
      _allDisable = false;
  int _stateCust = 0,
      _stateLoc = 0,
      _stateSup = 0,
      _stateInv = 0,
      _stateReason = 0,
      _stateAll = 0;
  List<InventoryHive> poSkuListing = [];
  // List<InventoryHive> _inventoryList = [];
  // List get inventoryList => _inventoryList;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return StmsScaffold(
      title: 'Master Screen',
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    minimumSize: Size(width * 0.35, height / 16),
                  ),
                  onPressed: _custDisable
                      ? null
                      : () {
                          downloadCustomer();
                        },
                  child: setUpButtonCust(),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vendor',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    minimumSize: Size(width * 0.35, height / 16),
                  ),
                  onPressed: _supDisable
                      ? null
                      : () {
                          downloadVendor();
                        },
                  child: setUpButtonSup(),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    minimumSize: Size(width * 0.35, height / 16),
                  ),
                  onPressed: _locDisable
                      ? null
                      : () {
                          downloadLocation();
                        },
                  child: setUpButtonLoc(),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    minimumSize: Size(width * 0.35, height / 16),
                  ),
                  onPressed: _invDisable
                      ? null
                      : () {
                          downloadInventory();
                        },
                  child: setUpButtonInv(),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reason Code',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    minimumSize: Size(width * 0.35, height / 16),
                  ),
                  onPressed: _reasonDisable
                      ? null
                      : () {
                          downloadReason();
                        },
                  child: setUpButtonReason(),
                ),
              ],
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    minimumSize: Size(width, height / 16),
                  ),
                  onPressed: _allDisable
                      ? null
                      : () {
                          downloadAll();
                        },
                  child: setUpButtonAll(),
                ),
              ),
            ),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.blueAccent,
            //     minimumSize: Size(width, height / 16),
            //   ),
            //   onPressed: () {
            //     DBMasterInventoryHive().deleteItem();
            //     // DBMasterCustomer().deleteAllMasterCust();
            //     // DBMasterInventory().deleteAllMasterInv().then((value) {
            //     // print('value delete: $value');
            //     // });
            //     // DBMasterLocation().deleteAllMasterLoc();
            //     // DBMasterSupplier().deleteAllMasterSupplier();
            //   },
            //   child: Text(
            //     'Delete',
            //     style: TextStyle(
            //       fontSize: 18.0,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.blueAccent,
            //     minimumSize: Size(width, height / 16),
            //   ),
            //   onPressed: () {
            //     // getItem();
            //     DBMasterInventoryHive().getAllInvHive().then((value) {
            //       print('hive value: $value');
            //       print('hive: ${value[0]['sku']}');
            //     });
            //   },
            //   // () {
            //   //   // DBMasterInventory().getAllMasterInv().then((value) {
            //   //   //   print('inv value: $value');
            //   //   // });
            //   // },
            //   child: Text(
            //     'View',
            //     style: TextStyle(
            //       fontSize: 18.0,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // getItem() async {
  //   final box = Hive.box<InventoryHive>('inventory');

  //   _inventoryList = box.values.toList();

  //   // notifyListeners();
  // }

  // List<InventoryHive> get fetchFromFavBox {
  //   // final _invBox = Hive.box<InventoryHive>('inventory');
  //   // final box = Hive.box('data');
  //   List<InventoryHive> invHive = [];

  //   invHive = box.values.toList();

  //   return invHive;

  //   // final box = Hive.box('data');
  //   // List<InventoryHive> characters = [];
  //   // for (var item in box.toMap().values) {
  //   //   characters.add(InventoryHive.fromJson(item));
  //   // }

  //   // print('hive: $characters');
  //   // return characters;
  // }

  // List<Character> get storedCharacters {
  //   final box = Hive.box('data');
  //   List<Character> characters = [];
  //   for (var item in box.toMap().values) {
  //     characters.add(Character.fromMap(item));
  //   }
  //   return characters;
  // }

  downloadCustomer() {
    if (!mounted) return;
    setState(() {
      animateCustButton();
    });

    CommonService().getCustomer().then(
      (value) async {
        await Future.delayed(const Duration(seconds: 6));
        showCustomSuccess('Successfully Download');

        setState(() {
          _stateCust = 0;
          _custDisable = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _stateCust = 0;
          _custDisable = false;
        });
      },
    );
  }

  downloadVendor() {
    if (!mounted) return;
    setState(() {
      animateSupButton();
    });

    CommonService().getSupplier().then(
      (value) async {
        await Future.delayed(const Duration(seconds: 6));
        showCustomSuccess('Successfully Download');

        setState(() {
          _stateSup = 0;
          _supDisable = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _stateSup = 0;
          _supDisable = false;
        });
      },
    );
  }

  downloadLocation() {
    if (!mounted) return;
    setState(() {
      animateLocButton();
    });

    CommonService().getLocation().then(
      (value) async {
        await Future.delayed(const Duration(seconds: 6));
        showCustomSuccess('Successfully Download');

        if (!mounted) return;
        setState(() {
          _stateLoc = 0;
          _locDisable = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _stateLoc = 0;
          _locDisable = false;
        });
      },
    );
  }

  downloadInventory() {
    if (!mounted) return;
    setState(() {
      animateInvButton();
    });

    CommonService().getInventory().then(
      (value) async {
        await Future.delayed(const Duration(seconds: 5)).then((value) {
          // DBMasterInventoryHive().getAllInvHive().then((value) {
          //   if (value == []) {
          //     print('not download');
          //   } else {
          //     print('downloaded');
          //   }
          // });
          showCustomSuccess('Successfully Download');

          if (!mounted) return;
          setState(() {
            _stateInv = 0;
            _invDisable = false;
          });
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _stateInv = 0;
          _invDisable = false;
        });
      },
    );
  }

  downloadReason() {
    if (!mounted) return;
    setState(() {
      animateReasonButton();
    });

    CommonService().getReason().then(
      (value) async {
        await Future.delayed(const Duration(seconds: 6));
        showCustomSuccess('Successfully Download');

        setState(() {
          _stateReason = 0;
          _reasonDisable = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _stateReason = 0;
          _reasonDisable = false;
        });
      },
    );
  }

  downloadAll() {
    if (!mounted) return;
    setState(() {
      animateAllButton();
    });

    CommonService().getCustomer().then((value) async {
      await Future.delayed(const Duration(seconds: 5));
    }).whenComplete(() {
      CommonService().getSupplier().then((value) async {
        await Future.delayed(const Duration(seconds: 5));
      }).whenComplete(() {
        CommonService().getLocation().then((value) async {
          await Future.delayed(const Duration(seconds: 5));
        }).whenComplete(() {
          CommonService().getReason().then((value) async {
            await Future.delayed(const Duration(seconds: 5));
          }).whenComplete(() {
            CommonService().getInventory().then((value) async {
              await Future.delayed(const Duration(seconds: 13));
            }).whenComplete(() {
              showCustomSuccess('Successfully Download');

              setState(() {
                _stateAll = 0;
                _allDisable = false;
              });
            });
          });
        });
      });
    });
  }

  Widget setUpButtonCust() {
    if (_stateCust == 0) {
      return Text(
        'Download',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        'Downloading...',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    }
  }

  Widget setUpButtonSup() {
    if (_stateSup == 0) {
      return Text(
        'Download',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        'Downloading...',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    }
  }

  Widget setUpButtonLoc() {
    if (_stateLoc == 0) {
      return Text(
        'Download',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        'Downloading...',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    }
  }

  Widget setUpButtonInv() {
    if (_stateInv == 0) {
      return Text(
        'Download',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        'Downloading...',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    }
  }

  Widget setUpButtonReason() {
    if (_stateReason == 0) {
      return Text(
        'Download',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        'Downloading...',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    }
  }

  Widget setUpButtonAll() {
    if (_stateAll == 0) {
      return Text(
        'Download All Master File',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        'Downloading...',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      );
    }
  }

  void animateCustButton() {
    setState(() {
      _stateCust = 1;
      _custDisable = true;
    });
  }

  void animateSupButton() {
    setState(() {
      _stateSup = 1;
      _supDisable = true;
    });
  }

  void animateLocButton() {
    setState(() {
      _stateLoc = 1;
      _locDisable = true;
    });
  }

  void animateInvButton() {
    setState(() {
      _stateInv = 1;
      _invDisable = true;
    });
  }

  void animateReasonButton() {
    setState(() {
      _stateReason = 1;
      _reasonDisable = true;
    });
  }

  void animateAllButton() {
    setState(() {
      _stateAll = 1;
      _allDisable = true;
    });
  }
}
