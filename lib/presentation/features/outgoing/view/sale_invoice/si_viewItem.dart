import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/models/outgoing/si/si_model.dart';
import 'package:stms/data/api/models/outgoing/si/si_non_model.dart';
import 'package:stms/data/api/repositories/api_json/api_common.dart';
import 'package:stms/data/api/repositories/api_json/api_out_saleInvoice.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/outgoing/si/si_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/si/si_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/custom_toast.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class SiItemDetails extends StatefulWidget {
  // final Function changeView;

  const SiItemDetails({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _SiItemDetailsState createState() => _SiItemDetailsState();
}

class _SiItemDetailsState extends State<SiItemDetails> {
  var getSaleInvoiceItem = SaleInvoiceService();
  var getCommonData = CommonService();

  List<InventoryHive> inventoryList = [];
  List siItemList = [];
  List getAllSiNonItems = [];
  List getAllSiItems = [];
  // String _scanBarcode = 'Unknown';
  var selectedInvtry, tracking;
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
    getItemSi();

    selectedInvtry = Storage().selectedInvId;

    fToast = FToast();
    fToast.init(context);
  }

  getItemSi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // serialNo = prefs.getString('itemBarcode')!;

    // selectedInvtry = prefs.getString('selectedSiID');

    if (prefs.getString('itemBarcode') != null) {
      itemSNController.text = prefs.getString('itemBarcode')!;
    }

    itemSelectedInventory.text = selectedInvtry;
    tracking = prefs.getString('siTracking');
  }

  getCommon() {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      print('detailValue: $value');

      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download inventory file at master page first');
      } else {
        setState(() {
          inventoryList = value;
        });
      }
    });
    DBSaleInvoiceItem().getAllSiItem().then((value){
      if(value != null){
        setState(() {
          getAllSiItems = value;
        });
      }
    });
    DBSaleInvoiceNonItem().getAllSiNonItem().then((value){
      if(value != null){
        setState(() {
          getAllSiNonItems = value;
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
                          keyboard: TextInputType.number,
                          validator: Validator.valueExists,
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

        if(itemAdjust == null){
          DBSaleInvoiceItem()
              .createSiItem(SaleInvoice(
            itemInvId: itemAdjust!.id,
            itemSerialNo: itemSNController.text,
          ))
              .then((value) {
            showCustomSuccess('Item Save');
            Navigator.popUntil(
                context, ModalRoute.withName(StmsRoutes.siItemList));
          });
        } else {
          if(itemAdjust.sku == itemSNController.text){
            ErrorDialog.showErrorDialog(
                context, 'Similar Serial Number present');
          } else {
            DBSaleInvoiceItem()
                .createSiItem(SaleInvoice(
              itemInvId: itemAdjust.id,
              itemSerialNo: itemSNController.text,
            ))
                .then((value) {
              showCustomSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.siItemList));
            });
          }
        }
      } else {
        var itemAdjust = inventoryList.firstWhereOrNull((element) =>
        element.sku == selectedInvtry);

        if(itemAdjust != null){
          DBSaleInvoiceNonItem().getAllSiNonItem().then((value){
            if(value == null){
              DBSaleInvoiceNonItem()
                  .createSiNonItem(SaleInvoiceNon(
                itemInvId: itemAdjust.id,
                nonTracking: itemQtyController.text,
              ))
                  .then((value) {
                showCustomSuccess('Item Save');
                Navigator.popUntil(
                    context, ModalRoute.withName(StmsRoutes.siItemList));
              });
            } else {
              List allDBValue = value;
              var itemTracking = allDBValue.firstWhereOrNull((element) =>
              element['item_inventory_id'] == itemAdjust.id);

              if(itemTracking != null){
                var newQty = int.parse(itemQtyController.text) + int.parse(itemTracking['non_tracking_qty']);
                DBSaleInvoiceNonItem()
                    .update(itemAdjust.id, newQty.toString())
                    .then((value) {
                  showCustomSuccess('Item Save');
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.siItemList));
                });
              } else {
                DBSaleInvoiceNonItem()
                    .createSiNonItem(SaleInvoiceNon(
                  itemInvId: itemAdjust.id,
                  nonTracking: itemQtyController.text,
                ))
                    .then((value) {
                  showCustomSuccess('Item Save');
                  Navigator.popUntil(
                      context, ModalRoute.withName(StmsRoutes.siItemList));
                });
              }
            }
          });
        }

        // if(itemAdjust == null){}else {
        //   var itemTracking = getAllSiNonItems.firstWhereOrNull((element) =>
        //   element['item_name'] == itemAdjust.sku);
        //   print('CHECK QTY: ${itemAdjust.sku}');
        //
        //
        //   if(itemTracking == null){
        //     DBSaleInvoiceNonItem()
        //         .createSiNonItem(SaleInvoiceNon(
        //       itemInvId: itemAdjust.id,
        //       nonTracking: itemQtyController.text,
        //     ))
        //         .then((value) {
        //       showCustomSuccess('Item Save');
        //       Navigator.popUntil(
        //           context, ModalRoute.withName(StmsRoutes.siItemList));
        //     });
        //   } else {
        //     print('CHECK QTY3: ${itemTracking['item_name']}');
        //     print('CHECK QTY2: ${itemQtyController.text}');
        //     DBSaleInvoiceNonItem()
        //         .update(itemAdjust.id, itemQtyController.text)
        //         .then((value) {
        //       showCustomSuccess('Item Save');
        //       Navigator.popUntil(
        //           context, ModalRoute.withName(StmsRoutes.siItemList));
        //     });
        //   }
        // }
      }
    }
  }
}
