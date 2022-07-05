import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/ai/aiItem_model.dart';
import 'package:stms/data/api/models/incoming/ai/ai_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/local_db/incoming/adjust_in/ai_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/adjust_in/ai_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class AiCreateItem extends StatefulWidget {
  const AiCreateItem({Key? key}) : super(key: key);

  @override
  _AiCreateItemState createState() => _AiCreateItemState();
}

class _AiCreateItemState extends State<AiCreateItem> {
  List<InventoryHive> inventoryList = [];
  List reasonList = [];
  List allAdjustInItem = [];
  List allAdjustInNonItem = [];
  var adjustInTrack, selectedInvtry, selectedReason;
  final TextEditingController itemSnController = TextEditingController();
  final TextEditingController itemNonQtyController = TextEditingController();
  final TextEditingController itemSelectedInventory = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSnKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemNonQtyKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemSelectedInvKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getData();
    getCommon();

    fToast = FToast();
    fToast.init(context);
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adjustInTrack = prefs.getString('adjustTracking');
    selectedInvtry = prefs.getString('adjustItem');
    itemSelectedInventory.text = selectedInvtry;
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
      // print('value loc: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download reason code file at master page first');
      } else {
        setState(() {
          // reasonList = value;
          reasonList = List.of(value);
          reasonList.sort((a, b) =>
              a["code"].toLowerCase().compareTo(b["code"].toLowerCase()));
          // print("resonList: $reasonList");
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
              child: Container(
                height: height * 0.85,
                child: Column(
                  children: [
                    // FormField<String>(
                    //   builder: (FormFieldState<String> state) {
                    //     return InputDecorator(
                    //       decoration: InputDecoration(
                    //         labelText: 'Item Inventory ID',
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
                    //             items: inventoryList.map((item) {
                    //               return new DropdownMenuItem(
                    //                 child: Container(
                    //                   width: width * 0.8,
                    //                   child: Text(
                    //                     item.sku,
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 ),
                    //                 value: item.id.toString(),
                    //               );
                    //             }).toList(),
                    //             isExpanded: false,
                    //             value:
                    //                 selectedInvtry, // == "" ? "" : selectedTxn,
                    //             onChanged: null,
                    //             // (String? newValue) {
                    //             //   setState(() {
                    //             //     selectedInvtry = newValue!;
                    //             //     // print('transfer type: $transferType');
                    //             //   });
                    //             // },
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),

                    // Text field for Item Inventory ID
                    TextField(
                      controller: itemSelectedInventory,
                      key: itemSelectedInvKey,
                      readOnly: true,
                      decoration: InputDecoration(
                          labelText: 'Item Inventory ID',
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          )
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    // TextField for Quantity or Serial Number
                    adjustInTrack == 'Serial Number'
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

                    // Text field for reason code
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
                                    child: new Text(
                                      item['code'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                            ),
                          ),
                        );
                      },
                    ),
                    // Save Button
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
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
                    SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Save Data option
  Future<void> saveData() async {
    if (selectedInvtry == null) {
      ErrorDialog.showErrorDialog(context, 'Please select item Inventory ID');
    } else if (adjustInTrack == "Serial Number" &&
        itemSnKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (adjustInTrack != "Serial Number" &&
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (selectedReason == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Reason Code');
    } else if (adjustInTrack != 'Serial Number' &&
        int.parse(itemNonQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (adjustInTrack == "Serial Number") {
        // Get all value from DB
        DBAdjustInItem().getAllAiItem().then((value){
          // Compare item name from DB
          var itemAdjust = inventoryList.firstWhereOrNull((element) =>
          element.sku == selectedInvtry);

          // First check if there is value or not
          // If got value
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyItem is the list
              adjustInTrack = value;

              // Check if SKU name present
              if(itemAdjust != null){
                // Compare item in DB with the sku name selected
                // search in DB if got the same item inventory id or not
                // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
                var currentItemInBD = allAdjustInItem.firstWhereOrNull((element) =>
                element['item_inventory_id'] == itemAdjust.id
                    && element['item_reason_code'] == selectedReason);

                // if already got item with the same item inventory id
                if (currentItemInBD != null) {
                  // display popup error and show popup error of the item already exist
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.aiItemList));
                  ErrorDialog.showErrorDialog(
                      context, 'Item Similar Reason Code already exists.');
                } else {
                  // if no item with this item inventory id
                  DBAdjustInItem()
                      .createAiItem(
                    AdjustInItem(
                      itemIvId: itemAdjust.id,
                      itemSn: itemSnController.text,
                      itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                    showCustomSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.aiItemList));
                  });
                }
              }
            });
            // if no value in DB at all
          } else {
            if(itemAdjust != null){
              DBAdjustInItem()
                  .createAiItem(
                AdjustInItem(
                  itemIvId: itemAdjust.id,
                  itemSn: itemSnController.text,
                  itemReason: selectedReason,
                ),
              )
                  .then((value) {
                showCustomSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.aiItemList));
              });
            }
          }
        });
      } else {
        // Get all value from DB
        DBAdjustInNonItem().getAllAiNonItem().then((value){
          var itemAdjust = inventoryList.firstWhereOrNull((element) =>
          element.sku == selectedInvtry);

          // First check if there is value or not
          // If got value
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyNonItem is the list
              allAdjustInNonItem = value;

              // Check if SKU name present
              if(itemAdjust != null) {
                // Compare item in DB with the sku name selected
                var currentItemInBD = allAdjustInNonItem.firstWhereOrNull((element) =>
                element['item_inventory_id'] == itemAdjust.id
                    && element['item_reason_code'] == selectedReason);

                // if already got item with the same item inventory id
                if(currentItemInBD != null){
                  // display popup error and show popup error of the item already exist
                  Navigator.popUntil(context, ModalRoute.withName(StmsRoutes.aiItemList));
                  ErrorDialog.showErrorDialog(context, 'Item Similar Reason Code already exists.');
                } else {
                    // if no item with this item inventory id
                    DBAdjustInNonItem()
                        .createAiNonItem(
                      AdjustInNonItem(
                        itemIvId: itemAdjust.id,
                        itemNonQty: itemNonQtyController.text,
                        itemReason: selectedReason,
                      ),
                    )
                        .then((value) {
                      showCustomSuccess('Item Save');
                      Navigator.popUntil(
                          context, ModalRoute.withName(StmsRoutes.aiItemList));
                    });
                }
              }
            });
            // if no value in DB at all
          } else {
            if(itemAdjust != null) {
              DBAdjustInNonItem()
                  .createAiNonItem(
                AdjustInNonItem(
                  itemIvId: itemAdjust.id,
                  itemNonQty: itemNonQtyController.text,
                  itemReason: selectedReason,
                ),
              )
                  .then((value) {
                showCustomSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.aiItemList));
              });
            }
          }
        });
      }
    }
  }
}
