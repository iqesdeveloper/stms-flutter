import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/vsr/vsrItem_model.dart';
import 'package:stms/data/api/models/incoming/vsr/vsr_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/local_db/incoming/vsr/vsr_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/vsr/vsr_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';
// import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class VsrCreateItem extends StatefulWidget {
  const VsrCreateItem({Key? key}) : super(key: key);

  @override
  _VsrCreateItemState createState() => _VsrCreateItemState();
}

class _VsrCreateItemState extends State<VsrCreateItem> {
  List<InventoryHive> inventoryList = [];
  List reasonList = [];
  List allVendorReplaceItem = [];
  List allVendorReplaceNonItem = [];
  var vsrTrack, selectedInvtry, selectedReason;
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
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    vsrTrack = prefs.getString('vsrTracking');
    selectedInvtry = prefs.getString('vsrItem');
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
                      vsrTrack == '2'
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
    } else if (vsrTrack == "2" && itemSnKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (vsrTrack != "2" &&
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (vsrTrack != '2' && int.parse(itemNonQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (vsrTrack == "2") {
        // Get all value from DB
        DBVendorReplaceItem().getAllVsrItem().then((value){
          var itemAdjust = inventoryList.firstWhereOrNull((element) =>
          element.sku == selectedInvtry);

          // First check if there is value or not
          // If got value
          // ignore: unnecessary_null_comparison
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyItem is the list
              allVendorReplaceItem = value;

              // Check if SKU name present
              if(itemAdjust != null) {
                // search in DB if got the same item inventory id or not
                // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
                var currentItemInBD = allVendorReplaceItem.firstWhereOrNull((
                    element) => element['item_inventory_id'] == itemAdjust.id);

                // if already got item with the same item inventory id
                if (currentItemInBD != null) {
                  // display popup error and show popup error of the item already exist
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.vsrItemList));
                  ErrorDialog.showErrorDialog(
                      context, 'Item SKU already exists.');
                } else {
                  // if no item with this item inventory id
                  DBVendorReplaceItem()
                      .createVsrItem(
                    VsrItem(
                      itemIvId: itemAdjust.id,
                      itemSn: itemSnController.text,
                      // itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                    showSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.vsrItemList));
                  });
                }
              }
            });
            // if no value in DB at all
          } else {
            if(itemAdjust != null) {
              DBVendorReplaceItem()
                  .createVsrItem(
                VsrItem(
                  itemIvId: itemAdjust.id,
                  itemSn: itemSnController.text,
                  // itemReason: selectedReason,
                ),
              )
                  .then((value) {
                showSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.vsrItemList));
              });
            }
          }
        });
      } else {
        // Get all value from DB
        DBVendorReplaceNonItem().getAllVsrNonItem().then((value) {
          var itemAdjust = inventoryList.firstWhereOrNull((element) =>
          element.sku == selectedInvtry);

          // First check if there is value or not
          // If got value
          // ignore: unnecessary_null_comparison
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyNonItem is the list
              allVendorReplaceNonItem = value;

              if(itemAdjust != null) {
                // search in DB if got the same item inventory id or not
                // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
                var currentItemInBD = allVendorReplaceNonItem.firstWhereOrNull((element)
                => element['item_inventory_id'] == itemAdjust.id);

                // if already got item with the same item inventory id
                if(currentItemInBD != null){
                  // display popup error and show popup error of the item already exist
                  Navigator.popUntil(context, ModalRoute.withName(StmsRoutes.vsrItemList));
                  ErrorDialog.showErrorDialog(context, 'Item SKU already exists.');
                } else {
                  // if no item with this item inventory id
                  DBVendorReplaceNonItem()
                      .createVsrNonItem(
                    VsrNonItem(
                      itemIvId: itemAdjust.id,
                      itemNonQty: itemNonQtyController.text,
                      // itemReason: selectedReason,
                    ),
                  )
                      .then((value) {
                    showSuccess('Item Save');
                    Navigator.popUntil(
                        context, ModalRoute.withName(StmsRoutes.vsrItemList));
                  });
                }
              }
            });
            // if no value in DB at all
          } else {
            if(itemAdjust != null) {
              DBVendorReplaceNonItem()
                  .createVsrNonItem(
                VsrNonItem(
                  itemIvId: itemAdjust.id,
                  itemNonQty: itemNonQtyController.text,
                  // itemReason: selectedReason,
                ),
              )
                  .then((value) {
                showSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.vsrItemList));
              });
            }
          }
        });
      }
    }
  }
}
