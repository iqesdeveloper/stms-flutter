import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/im/imItem_model.dart';
import 'package:stms/data/api/models/incoming/im/im_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/local_db/incoming/im/im_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/im/im_scanItem.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class ImCreateItem extends StatefulWidget {
  const ImCreateItem({Key? key}) : super(key: key);

  @override
  _ImCreateItemState createState() => _ImCreateItemState();
}

class _ImCreateItemState extends State<ImCreateItem> {
  List<InventoryHive> inventoryList = [];
  List reasonList = [];
  var itemModifyTrack, selectedInvtry, selectedReason;
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
    itemModifyTrack = prefs.getString('imTracking');
    selectedInvtry = prefs.getString('imItem');
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
            title: 'Item Modification',
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
                                  //   });
                                  // },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      itemModifyTrack == 'Serial Number'
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
    } else if (itemModifyTrack == "Serial Number" &&
        itemSnKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else if (itemModifyTrack != "Serial Number" &&
        itemNonQtyKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Quantity cannot be empty');
    } else if (selectedReason == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Reason Code');
    } else if (itemModifyTrack != 'Serial Number' &&
        int.parse(itemNonQtyController.text) <= 0) {
      ErrorDialog.showErrorDialog(context, 'Minimum quantity is 1');
    } else {
      if (itemModifyTrack == "Serial Number") {
        DBItemModifyItem()
            .createImItem(ItemModifyItem(
          itemIvId: selectedInvtry,
          itemSn: itemSnController.text,
          itemReason: selectedReason,
        ))
            .then((value) {
          showSuccess('Item Save');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.imItemList));
        });
      } else {
        DBItemModifyNonItem()
            .createImNonItem(
          ItemModifyNonItem(
            itemIvId: selectedInvtry,
            itemNonQty: itemNonQtyController.text,
            itemReason: selectedReason,
          ),
        )
            .then((value) {
          showSuccess('Item Save');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.imItemList));
        });
      }
    }
  }
}
