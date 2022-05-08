import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/transfer/stItem_model.dart';
import 'package:stms/data/api/models/transfer/st_non_model.dart';
import 'package:stms/data/local_db/master/master_inventory_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/data/local_db/transfer/st_non_scanItem.dart';
import 'package:stms/data/local_db/transfer/st_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class StCreateItem extends StatefulWidget {
  const StCreateItem({Key? key}) : super(key: key);

  @override
  _StCreateItemState createState() => _StCreateItemState();
}

class _StCreateItemState extends State<StCreateItem> {
  List inventoryList = [];
  List reasonList = [];
  var transferTrack, selectedInvtry, selectedReason;
  final TextEditingController itemSnController = TextEditingController();
  final TextEditingController itemNonQtyController = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSnKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemNonQtyKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getData();
    getCommon();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    transferTrack = prefs.getString('transferTracking');
    selectedInvtry = prefs.getString('transferItem');
    itemSnController.text = prefs.getString('itemBarcode')!;
  }

  getCommon() {
    DBMasterInventory().getAllMasterInv().then((value) {
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
          reasonList = List.of(value);
          reasonList.sort((a, b) =>
              a["code"].toLowerCase().compareTo(b["code"].toLowerCase()));
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
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Container(
                  height: height * 0.85,
                  child: Column(
                    children: [
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Item Inventory ID',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: new DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  iconSize: 28,
                                  iconEnabledColor: Colors.amber,
                                  items: inventoryList.map((item) {
                                    return new DropdownMenuItem(
                                      child: Container(
                                          width: width * 0.8,
                                          child: Text(item['sku'])),
                                      value: item['id'].toString(),
                                    );
                                  }).toList(),
                                  isExpanded: false,
                                  value:
                                      selectedInvtry, // == "" ? "" : selectedTxn,
                                  onChanged: null,
                                  // (String? newValue) {
                                  //   setState(() {
                                  //     selectedInvtry = newValue!;
                                  //     // print('transfer type: $transferType');
                                  //   });
                                  // },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      transferTrack == 'Serial Number' || transferTrack == '2'
                          ? StmsInputField(
                              controller: itemSnController,
                              hint: 'Serial No',
                              key: itemSnKey,
                              validator: Validator.valueExists,
                            )
                          : StmsInputField(
                              controller: itemNonQtyController,
                              hint: 'Quantity',
                              key: itemNonQtyKey,
                              keyboard: TextInputType.number,
                              validator: Validator.valueExists,
                            ),
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Reason Code',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: new DropdownButtonHideUnderline(
                                child: ButtonTheme(
                              child: DropdownButton<String>(
                                isDense: true,
                                iconSize: 28,
                                iconEnabledColor: Colors.amber,
                                items: reasonList.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(item['code']),
                                    value: item['id'].toString(),
                                  );
                                }).toList(),
                                isExpanded: false,
                                value:
                                    selectedReason, // == "" ? "" : selectedTxn,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedReason = newValue!;
                                    // print('transfer type: $transferType');
                                  });
                                },
                              ),
                            )),
                          );
                        },
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: height*0.08,
                            child: StmsStyleButton(
                              title: 'SAVE',
                              backgroundColor: Colors.amber,
                              textColor: Colors.black,
                              onPressed: () {
                                saveData();
                                // Navigator.popUntil(context,
                                //     ModalRoute.withName(StmsRoutes.aiItemList));
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (selectedInvtry == null) {
      ErrorDialog.showErrorDialog(context, 'Please select item Inventory ID');
    } else if (itemSnKey.currentState?.validate() != null ||
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (selectedReason == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Reason Code');
    } else {
      if (transferTrack == "Serial Number" || transferTrack == "2") {
        DBStockTransItem()
            .createStItem(
          StockTransItem(
            itemIvId: selectedInvtry,
            itemSn: itemSnController.text,
            itemReason: selectedReason,
          ),
        )
            .then((value) {
          showSuccess('Item Save');
          prefs.remove('itemBarcode');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.stItemList));
        });
      } else {
        if (int.parse(itemNonQtyController.text) <= 0) {
          ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
        } else {
          if (Storage().transfer == '1') {
            DBStockTransNonItem().getAllStNonItem().then((value) {
              if (value != null) {
                List listingSt = value;

                var itemSt = listingSt.firstWhereOrNull((element) =>
                    element['item_inventory_id'] == selectedInvtry);
                if (null == itemSt) {
                  String? getQty = prefs.getString('itemQty');
                  var currentQty = int.parse(getQty!);

                  if (int.parse(itemNonQtyController.text) <= currentQty) {
                    DBStockTransNonItem()
                        .createStNonItem(
                      StockTransNonItem(
                        itemIvId: selectedInvtry,
                        itemNonQty: itemNonQtyController.text,
                        itemReason: selectedReason,
                      ),
                    )
                        .then((value) {
                      showSuccess('Item Save');
                      Navigator.popUntil(
                          context, ModalRoute.withName(StmsRoutes.stItemList));
                    });
                  } else {
                    ErrorDialog.showErrorDialog(
                        context, 'Quantity cannot more than current quantity.');
                  }
                } else {
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.stItemList));

                  ErrorDialog.showErrorDialog(
                      context, 'This SKU already exists.');
                }
              } else {
                String? getQty = prefs.getString('itemQty');
                var currentQty = int.parse(getQty!);

                if (int.parse(itemNonQtyController.text) <= currentQty) {
                  DBStockTransNonItem()
                      .createStNonItem(
                    StockTransNonItem(
                      itemIvId: selectedInvtry,
                      itemNonQty: itemNonQtyController.text,
                      itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                    showSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.stItemList));
                  });
                } else {
                  ErrorDialog.showErrorDialog(
                      context, 'Quantity cannot more than current quantity.');
                }
              }
            });
          } else {
            DBStockTransNonItem().getAllStNonItem().then((value) {
              if (value != null) {
                List listingSt = value;

                var itemSt = listingSt.firstWhereOrNull((element) =>
                    element['item_inventory_id'] == selectedInvtry);
                if (null == itemSt) {
                  DBStockTransNonItem()
                      .createStNonItem(
                    StockTransNonItem(
                      itemIvId: selectedInvtry,
                      itemNonQty: itemNonQtyController.text,
                      itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                    showSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.stItemList));
                  });
                } else {
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.stItemList));

                  ErrorDialog.showErrorDialog(
                      context, 'This SKU already exists.');
                }
              } else {
                DBStockTransNonItem()
                    .createStNonItem(
                  StockTransNonItem(
                    itemIvId: selectedInvtry,
                    itemNonQty: itemNonQtyController.text,
                    itemReason: selectedReason,
                  ),
                )
                    .then((value) {
                  showSuccess('Item Save');
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.stItemList));
                });
              }
            });
          }
        }
      }
    }
  }
}
