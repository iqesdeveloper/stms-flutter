import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/incoming/paiv/paiv_model.dart';
import 'package:stms/data/api/models/incoming/paiv/paiv_non_model.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/repositories/api_json/api_common.dart';
import 'package:stms/data/api/repositories/api_json/api_in_paiv.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_scanItem_db.dart';
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

class PaivItemDetails extends StatefulWidget {
  // final Function changeView;

  const PaivItemDetails({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _PaivItemDetailsState createState() => _PaivItemDetailsState();
}

class _PaivItemDetailsState extends State<PaivItemDetails> {
  var getPaivItem = PaivService();
  var getCommonData = CommonService();

  List<InventoryHive> inventoryList = [];
  List paivItemList = [];
  List getAllPaivNonItems = [];
  List getAllPaivItems = [];
  // String _scanBarcode = 'Unknown';
  var selectedInvtry, tracking;
  final format = DateFormat("yyyy-MM-dd");
  final TextEditingController itemSNController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final TextEditingController itemUomController = TextEditingController();
  final TextEditingController itemUomQtyController = TextEditingController();
  final TextEditingController itemSelectedInventory = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemQtyKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemUomKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemUomQtyKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemSelectedInvKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getCommon();
    getItemPaiv();

    fToast = FToast();
    fToast.init(context);
  }

  getItemPaiv() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // serialNo = prefs.getString('itemBarcode')!;
    // await Future.delayed(const Duration(seconds: 1));
    selectedInvtry = prefs.getString('selectedPaIvID');
    itemSNController.text = prefs.getString('itemBarcode')!;
    itemSelectedInventory.text = selectedInvtry;
    tracking = prefs.getString('paivTracking');
  }

  getCommon() {
    DBMasterInventoryHive().getAllInvHive().then((value) {
      // print('detailValue: $value');

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
          // if (selectedInvtry == null) {
          //   return Container(
          //     height: MediaQuery.of(context).size.height,
          //     width: MediaQuery.of(context).size.width,
          //     color: Colors.white,
          //     child: Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   );
          // }
          return StmsScaffold(
            title: '',
            body: Container(
              height: height * 0.9,
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
          DBPaivItem()
              .createPaivItem(PaivItem(
            itemInvId: itemAdjust!.id,
            itemSerialNo: itemSNController.text,
          ))
              .then((value) {
            // SuccessDialog.showSuccessDialog(context, 'Item Save');
            showCustomSuccess('Item Save');
            Navigator.popUntil(
                context, ModalRoute.withName(StmsRoutes.paivItemList));
          });
        } else {
          ErrorDialog.showErrorDialog(
              context, 'Similar Serial Number present');
        }
      } else {
        var itemAdjust = inventoryList.firstWhereOrNull((element) =>
        element.sku == selectedInvtry);


        if(itemAdjust == null){
          DBPaivNonItem()
              .createPaivNonItem(PaivNonItem(
            itemInvId: itemAdjust!.id,
            nonTracking: itemQtyController.text,
          ))
              .then((value) {
            // SuccessDialog.showSuccessDialog(context, 'Item Save');
            showCustomSuccess('Item Save');
            Navigator.popUntil(
                context, ModalRoute.withName(StmsRoutes.paivItemList));
          });
        } else {
          DBPaivNonItem()
              .update(itemAdjust.id, itemQtyController.text)
              .then((value) {
            showCustomSuccess('Item Save');
            Navigator.popUntil(
                context, ModalRoute.withName(StmsRoutes.paivItemList));
          });
        }
      }
    }
  }
}
