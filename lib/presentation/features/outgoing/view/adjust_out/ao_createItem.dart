import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/models/outgoing/ao/aoItem_model.dart';
import 'package:stms/data/api/models/outgoing/ao/ao_non_model.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/data/local_db/outgoing/adjust_out/ao_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/adjust_out/ao_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class AoCreateItem extends StatefulWidget {
  const AoCreateItem({Key? key}) : super(key: key);

  @override
  _AoCreateItemState createState() => _AoCreateItemState();
}

class _AoCreateItemState extends State<AoCreateItem> {
  List<InventoryHive> inventoryList = [];
  List reasonList = [];
  List allAdjustOutItem = [];
  List allAdjustOutNonItem = [];
  var adjustOutTrack, selectedInvtry, selectedReason;
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
    adjustOutTrack = prefs.getString('adjustTracking');
    selectedInvtry = prefs.getString('adjustItem');
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
                                          child: Text(item.sku)),
                                      value: item.id.toString(),
                                    );
                                  }).toList(),
                                  isExpanded: false,
                                  value:
                                      selectedInvtry, // == "" ? "" : selectedTxn,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedInvtry = newValue!;
                                      // print('transfer type: $transferType');
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      adjustOutTrack == 'Serial Number'
                          ? StmsInputField(
                              controller: itemSnController,
                              hint: 'Serial No',
                              key: itemSnKey,
                              validator: Validator.valueExists,
                            )
                          : StmsInputField(
                              controller: itemNonQtyController,
                              hint: 'Quantity',
                              keyboard: TextInputType.number,
                              key: itemNonQtyKey,
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
                              ),
                            ),
                          );
                        },
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
    if (selectedInvtry == null) {
      ErrorDialog.showErrorDialog(context, 'Please select item Inventory ID');
    } else if (adjustOutTrack == "Serial Number" &&
        itemSnKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (adjustOutTrack != "Serial Number" &&
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (selectedReason == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Reason Code');
    } else if (adjustOutTrack != 'Serial Number' &&
        int.parse(itemNonQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (adjustOutTrack == "Serial Number") {
        // Get all value from DB
        DBAdjustOutItem().getAllAoItem().then((value){
          // First check if there is value or not
          // If got value
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyItem is the list
              adjustOutTrack = value;

              // search in DB if got the same item inventory id or not
              // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
              var currentItemInBD = allAdjustOutItem.firstWhereOrNull((
                  element) => element['item_inventory_id'] == selectedInvtry);

              // if already got item with the same item inventory id
              if (currentItemInBD != null) {
                // display popup error and show popup error of the item already exist
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.aoItemList));
                ErrorDialog.showErrorDialog(
                    context, 'Item SKU already exists.');
              } else {
                // if no item with this item inventory id
                DBAdjustOutItem()
                    .createAoItem(
                  AdjustOutItem(
                    itemIvId: selectedInvtry,
                    itemSn: itemSnController.text,
                    itemReason: selectedReason,
                  ),
                )
                    .then((value) {
                  showSuccess('Item Save');
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.aoItemList));
                });
              }
            });
            // if no value in DB at all
          } else {
            DBAdjustOutItem()
                .createAoItem(
              AdjustOutItem(
                itemIvId: selectedInvtry,
                itemSn: itemSnController.text,
                itemReason: selectedReason,
              ),
            )
                .then((value) {
              showSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.aoItemList));
            });
          }
        });
      } else {
        // Get all value from DB
        DBAdjustOutNonItem().getAllAoNonItem().then((value){
          // First check if there is value or not
          // If got value
          if(value != null){
            setState(() {
              // set the value to list
              // variable allModifyNonItem is the list
              allAdjustOutNonItem = value;

              // search in DB if got the same item inventory id or not
              // Also make sure the same item inventory id is equal to the item inventory id that in selected before getting to this page
              var currentItemInBD = allAdjustOutNonItem.firstWhereOrNull((element) => element['item_inventory_id'] == selectedInvtry);

              // if already got item with the same item inventory id
              if(currentItemInBD != null){
                // display popup error and show popup error of the item already exist
                Navigator.popUntil(context, ModalRoute.withName(StmsRoutes.aoItemList));
                ErrorDialog.showErrorDialog(context, 'Item SKU already exists.');
              } else {
                // if no item with this item inventory id
                DBAdjustOutNonItem()
                    .createAoNonItem(
                  AdjustOutNonItem(
                    itemIvId: selectedInvtry,
                    itemNonQty: itemNonQtyController.text,
                    itemReason: selectedReason,
                  ),
                )
                    .then((value) {
                  showSuccess('Item Save');
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.aoItemList));
                });
              }
            });
            // if no value in DB at all
          } else {
            DBAdjustOutNonItem()
                .createAoNonItem(
              AdjustOutNonItem(
                itemIvId: selectedInvtry,
                itemNonQty: itemNonQtyController.text,
                itemReason: selectedReason,
              ),
            )
                .then((value) {
              showSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.aoItemList));
            });
          }
        });
      }
    }
  }
}
