import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/cr/crItem_model.dart';
import 'package:stms/data/api/models/incoming/cr/cr_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/local_db/incoming/cr/cr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/cr/cr_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

import '../../../../widgets/independent/custom_toast.dart';

class CrCreateItem extends StatefulWidget {
  const CrCreateItem({Key? key}) : super(key: key);

  @override
  _CrCreateItemState createState() => _CrCreateItemState();
}

class _CrCreateItemState extends State<CrCreateItem> {
  List<InventoryHive> inventoryList = [];
  List reasonList = [];
  List allCustomerReturnItem = [];
  List allCustomerReturnNonItem = [];
  var custRetTrack, selectedInvtry, selectedReason;
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
    custRetTrack = prefs.getString('crTracking');
    selectedInvtry = prefs.getString('crItem');
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
                    custRetTrack == 'Serial Number'
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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (selectedInvtry == null) {
      ErrorDialog.showErrorDialog(context, 'Please select item Inventory ID');
    } else if (custRetTrack == "Serial Number" &&
        itemSnKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (custRetTrack != "Serial Number" &&
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (custRetTrack != 'Serial Number' &&
        int.parse(itemNonQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (custRetTrack == "Serial Number") {
        // Get all value from DB
        DBCustReturnItem().getAllCrItem().then((value){
          // Compare item name from DB
          var itemAdjust = inventoryList.firstWhereOrNull((element) => element.sku == selectedInvtry);

          // First check if there is value or not
          // If got value
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyItem is the list
              allCustomerReturnItem = value;

              // Check if SKU name present
              if(itemAdjust != null){
                // search in DB if got the same item inventory id or not
                // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
                var currentItemInBD = allCustomerReturnItem.firstWhereOrNull((
                    element) => element['item_inventory_id'] == itemAdjust.id
                    && element['item_name'] == itemAdjust.sku);

                print('TEST: $currentItemInBD');
                print('TEST2: ${itemAdjust.sku}');

                // if already got item with the same item inventory id
                if (currentItemInBD != null) {
                  // display popup error and show popup error of the item already exist
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.crItemList));
                  ErrorDialog.showErrorDialog(
                      context, 'Item SKU already exists.');
                } else {
                  // if no item with this item inventory id
                  DBCustReturnItem()
                      .createCrItem(
                    CustRetItem(
                      itemIvId: itemAdjust.id,
                      itemSn: itemSnController.text,
                      // itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                    showCustomSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.crItemList));
                  });
                }
              }
            });
            // if no value in DB at all
          } else {
            if(itemAdjust != null){
              DBCustReturnItem()
                  .createCrItem(
                CustRetItem(
                  itemIvId: itemAdjust.id,
                  itemSn: itemSnController.text,
                  // itemReason: selectedReason,
                ),
              )
                  .then((value) {
                showCustomSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.crItemList));
              });
            }
          }
        });
      } else {
        // Get all value from DB
        DBCustReturnNonItem().getAllCrNonItem().then((value) {
          var itemAdjust = inventoryList.firstWhereOrNull((element) =>
          element.sku == selectedInvtry);

          // First check if there is value or not
          // If got value
          // ignore: unnecessary_null_comparison
          if (value != null) {
            setState(() {
              // set the value to list
              // variable allModifyNonItem is the list
              allCustomerReturnNonItem = value;

              // Check if SKU name present
              if(itemAdjust != null) {
                // search in DB if got the same item inventory id or not
                // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
                var currentItemInBD = allCustomerReturnNonItem.firstWhereOrNull((element)
                => element['item_inventory_id'] == itemAdjust.id);

                // if already got item with the same item inventory id
                if(currentItemInBD != null){
                  // display popup error and show popup error of the item already exist
                  Navigator.popUntil(context, ModalRoute.withName(StmsRoutes.crItemList));
                  ErrorDialog.showErrorDialog(context, 'Item SKU already exists.');
                } else {
                  // if no item with this item inventory id
                  DBCustReturnNonItem()
                      .createCrNonItem(
                    CustRetNonItem(
                      itemIvId: itemAdjust.id,
                      itemNonQty: itemNonQtyController.text,
                      // itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                        showCustomSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.crItemList));
                  });
                }
              }
            });
            // if no value in DB at all
          } else {
            if(itemAdjust != null) {
              DBCustReturnNonItem()
                  .createCrNonItem(
                CustRetNonItem(
                  itemIvId: itemAdjust.id,
                  itemNonQty: itemNonQtyController.text,
                  // itemReason: selectedReason,
                ),
              )
                  .then((value) {
               showCustomSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.crItemList));
              });
            }
          }
        });
      }
    }
  }
}
