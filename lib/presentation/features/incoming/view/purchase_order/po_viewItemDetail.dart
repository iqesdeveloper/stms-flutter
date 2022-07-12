import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/po/po_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_common.dart';
import 'package:stms/data/api/repositories/api_json/api_in_po.dart';
import 'package:stms/data/local_db/incoming/po/po_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/po/po_scanItem_db.dart';
import 'package:stms/data/api/models/incoming/po/po_model.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class PoItemDetails extends StatefulWidget {
  // final Function changeView;

  const PoItemDetails({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _PoItemDetailsState createState() => _PoItemDetailsState();
}

class _PoItemDetailsState extends State<PoItemDetails> {
  var getPurchaseOrderItem = IncomingService();
  var getCommonData = CommonService();

  List<InventoryHive> inventoryList = [];
  List poItemList = [];
  List getAllPoNonItems = [];
  List getAllPoItems = [];
  // String _scanBarcode = 'Unknown';
  var selectedInvtry, selectedVendorItem, selectedItemSequence,tracking;
  final format = DateFormat("yyyy-MM-dd");
  final TextEditingController itemSNController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final TextEditingController itemSelectedInventory = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemQtyKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemSelectedInvKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getCommon();
    getItemPo();

    fToast = FToast();
    fToast.init(context);
  }

  getItemPo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // serialNo = prefs.getString('itemBarcode')!;

    selectedInvtry = prefs.getString('selectedIvID');
    selectedVendorItem = prefs.getString('vendorItemNo');

    if (tracking == "2") {
      itemSNController.text = prefs.getString('itemBarcode')!;
    } else {
      itemSNController.text = prefs.getString('itemBarcode')!;
    }

    selectedItemSequence = prefs.getString('line_seq_no');
    itemSelectedInventory.text = selectedInvtry;
    tracking = prefs.getString('poTracking');
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
    DBPoItem().getAllPoItem().then((value){
      if(value != null){
        setState(() {
          getAllPoItems = value;
        });
      }
    });
    DBPoNonItem().getAllPoNonItem().then((value){
      if(value != null){
        setState(() {
          getAllPoNonItems = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
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
              child: Column(
                children: [
                  // FormField<String>(
                  //   builder: (FormFieldState<String> state) {
                  //     return InputDecorator(
                  //       decoration: InputDecoration(
                  //         labelText: 'Item Inventory ID',
                  //         errorText: state.hasError ? state.errorText : null,
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
                  //             selectedInvtry, // == "" ? "" : selectedTxn,
                  //             onChanged: null,
                  //             // (String? newValue) {
                  //             //   setState(() {
                  //             //     selectedLoc = newValue!;
                  //             //     // print('transfer type: $transferType');
                  //             //   });
                  //             // },
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  TextField(
                    controller: itemSelectedInventory,
                    key: itemSelectedInvKey,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: 'Item Inventory ID',
                    ),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  tracking == "2"
                      ? StmsInputField(
                    key: itemSNKey,
                    controller: itemSNController,
                    hint: 'Item Serial No',
                    validator: Validator.valueExists,
                  )
                      : StmsInputField(
                    key: itemQtyKey,
                    controller: itemQtyController,
                    hint: 'Quantity',
                    validator: Validator.valueExists,
                    keyboard: TextInputType.number,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: ButtonTheme(
                          minWidth: 200,
                          height: 50,
                          child: StmsStyleButton(
                            title: 'SAVE',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () {
                              saveData();
                            },
                          ),
                        ),
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

  Future<void> saveData() async {

    if (tracking == "2" && itemSNKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (tracking != "2" && itemQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Item Quantity cannot be empty');
    } else if (tracking != '2' && int.parse(itemQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (tracking == "2") {
        var itemAdjust = inventoryList.firstWhereOrNull((element) =>
        element.sku == selectedInvtry);

        var itemSequence = getAllPoItems.firstWhereOrNull((element) =>
        element['line_seq_no'] == selectedItemSequence);

        print('ITEM ADJUST: $itemAdjust');
        print('ITEM SEQUENCE: $itemSequence');

        if(itemAdjust == null){} else {
          if(itemSequence == null){
            DBPoItem()
                .createPoItem(PoItem(
              itemInvId: itemAdjust.id,
              vendorItemNo: selectedVendorItem,
              itemSequence: selectedItemSequence,
              itemSerialNo: itemSNController.text,
            ))
                .then((value) {
              // SuccessDialog.showSuccessDialog(context, 'Item Save');
              showCustomSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.poItemList));
            });
          } else {
            if(itemSequence['line_seq_no'] == selectedItemSequence &&
                itemSequence['item_serial_no'] == itemSNController.text &&
                itemSequence['vendor_item_number'] == itemSNController.text){
              ErrorDialog.showErrorDialog(
                  context, 'Similar Serial Number present');
            } else {
              DBPoItem()
                  .createPoItem(PoItem(
                itemInvId: itemAdjust.id,
                vendorItemNo: selectedVendorItem,
                itemSequence: selectedItemSequence,
                itemSerialNo: itemSNController.text,
              ))
                  .then((value) {
                // SuccessDialog.showSuccessDialog(context, 'Item Save');
                showCustomSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.poItemList));
              });
            }
          }
        }
      } else {
        var itemAdjust = inventoryList.firstWhereOrNull((element) =>
        element.sku == selectedInvtry);

        var itemSequence = getAllPoNonItems.firstWhereOrNull((element) =>
        element['line_seq_no'] == selectedItemSequence);

        if(itemAdjust == null){} else {
          if(itemSequence == null){
            DBPoNonItem()
                .createPoNonItem(PoNonItem(
              itemInvId: itemAdjust.id,
              vendorItemName: selectedVendorItem,
              itemSequence: selectedItemSequence,
              nonTracking: itemQtyController.text,
            ))
                .then((value) {
              // SuccessDialog.showSuccessDialog(context, 'Item Save');
              showCustomSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.poItemList));
            });
          } else {
            print('ITEM SEQUENCE: $itemSequence}');
            var newQty = int.parse(itemQtyController.text) +
                int.parse(itemSequence['non_tracking_qty']);
            print('Check non tracking: $newQty');
            DBPoNonItem()
                .update(itemAdjust.id, newQty.toString(), selectedItemSequence)
                .then((value) {
              showCustomSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.poItemList));
            });
          }
        }
      }
    }
  }
}
