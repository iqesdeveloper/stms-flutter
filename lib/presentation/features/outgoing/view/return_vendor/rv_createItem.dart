import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/models/outgoing/rv/rvItem_model.dart';
import 'package:stms/data/api/models/outgoing/rv/rv_non_model.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/data/local_db/outgoing/rv/rv_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/rv/rv_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class RvCreateItem extends StatefulWidget {
  const RvCreateItem({Key? key}) : super(key: key);

  @override
  _RvCreateItemState createState() => _RvCreateItemState();
}

class _RvCreateItemState extends State<RvCreateItem> {
  List<InventoryHive> inventoryList = [];
  List reasonList = [];
  var rvTrack, selectedInvtry, selectedReason;
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
    rvTrack = prefs.getString('rvTracking');
    selectedInvtry = prefs.getString('rvItem');
    itemSnController.text = prefs.getString('itemBarcode')!;
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
                                        child: Text(
                                          item.sku,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      value: item.id.toString(),
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
                      rvTrack == '2'
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
                      // FormField<String>(
                      //   builder: (FormFieldState<String> state) {
                      //     return InputDecorator(
                      //       decoration: InputDecoration(
                      //         labelText: 'Reason Code',
                      //         errorText:
                      //             state.hasError ? state.errorText : null,
                      //       ),
                      //       isEmpty: false,
                      //       child: new DropdownButtonHideUnderline(
                      //         child: ButtonTheme(
                      //           child: DropdownButton<String>(
                      //             isDense: true,
                      //             iconSize: 28,
                      //             iconEnabledColor: Colors.amber,
                      //             items: reasonList.map((item) {
                      //               return new DropdownMenuItem(
                      //                 child: new Text(
                      //                   item['code'],
                      //                   overflow: TextOverflow.ellipsis,
                      //                 ),
                      //                 value: item['id'].toString(),
                      //               );
                      //             }).toList(),
                      //             isExpanded: false,
                      //             value:
                      //                 selectedReason, // == "" ? "" : selectedTxn,
                      //             onChanged: (String? newValue) {
                      //               setState(() {
                      //                 selectedReason = newValue!;
                      //                 // print('transfer type: $transferType');
                      //               });
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
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
    } else if (rvTrack == "2" && itemSnKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (rvTrack != "2" &&
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (rvTrack != '2' && int.parse(itemNonQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (rvTrack == "2") {
        DBReturnVendorItem()
            .createRvItem(
          RvItem(
            itemIvId: selectedInvtry,
            itemSn: itemSnController.text,
            // itemReason: selectedReason,
          ),
        )
            .then((value) {
          showSuccess('Item Save');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.rvItemList));
        });
      } else {
        DBReturnVendorNonItem().getAllRvNonItem().then((value) {
          // ignore: unnecessary_null_comparison
          if (value != null) {
            print('listing: $value');
            var listingRv = value;

            var itemRv = listingRv.firstWhereOrNull(
                (element) => element['item_inventory_id'] == selectedInvtry);
            print('itemRv check: $itemRv');

            if (null == itemRv) {
              String? getQty = prefs.getString('itemQty');
              var currentQty = int.parse(getQty!);
              if (int.parse(itemNonQtyController.text) <= currentQty) {
                DBReturnVendorNonItem()
                    .createRvNonItem(
                  RvNonItem(
                    itemIvId: selectedInvtry,
                    itemNonQty: itemNonQtyController.text,
                    // itemReason: selectedReason,
                  ),
                )
                    .then((value) {
                  showSuccess('Item Save');
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.rvItemList));
                });
              } else {
                ErrorDialog.showErrorDialog(
                    context, 'Quantity cannot more than current quantity.');
              }
            } else {
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.rvItemList));

              ErrorDialog.showErrorDialog(context, 'This SKU already exists.');
            }
          } else {
            DBReturnVendorNonItem()
                .createRvNonItem(
              RvNonItem(
                itemIvId: selectedInvtry,
                itemNonQty: itemNonQtyController.text,
                // itemReason: selectedReason,
              ),
            )
                .then((value) {
              showSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.rvItemList));
            });
          }
        });
      }
    }
  }
}
