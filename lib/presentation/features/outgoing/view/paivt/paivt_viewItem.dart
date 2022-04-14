import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/models/outgoing/paivt/paivt_model.dart';
import 'package:stms/data/api/models/outgoing/paivt/paivt_non_model.dart';
import 'package:stms/data/api/repositories/api_json/api_common.dart';
import 'package:stms/data/api/repositories/api_json/api_out_paivt.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/outgoing/paivt/paivt_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/paivt/paivt_scanItem.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class PaivtItemDetails extends StatefulWidget {
  // final Function changeView;

  const PaivtItemDetails({Key? key})
      : super(key: key); //, required this.changeView

  @override
  _PaivtItemDetailsState createState() => _PaivtItemDetailsState();
}

class _PaivtItemDetailsState extends State<PaivtItemDetails> {
  var getPaivtItem = PaivtService();
  var getCommonData = CommonService();

  List<InventoryHive> inventoryList = [];
  List paivtItemList = [];
  // String _scanBarcode = 'Unknown';
  var selectedInvtry, tracking;
  final format = DateFormat("yyyy-MM-dd");
  final TextEditingController itemSNController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final TextEditingController itemUomController = TextEditingController();
  final TextEditingController itemUomQtyController = TextEditingController();
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemQtyKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemUomKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> itemUomQtyKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getCommon();
    getItemPaivt();
  }

  getItemPaivt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // serialNo = prefs.getString('itemBarcode')!;

    selectedInvtry = prefs.getString('selectedPaivtID');
    itemSNController.text = prefs.getString('itemBarcode')!;
    tracking = prefs.getString('paivtTracking');
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
            body: SingleChildScrollView(
              child: Container(
                height: height * 0.9,
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Item Inventory ID',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              isDense: true,
                              iconSize: 28,
                              iconEnabledColor: Colors.amber,
                              items: inventoryList.map((item) {
                                return new DropdownMenuItem(
                                  child: Container(
                                    width: width * 0.8,
                                    child: Text(item.sku),
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
                              //     selectedLoc = newValue!;
                              //     // print('transfer type: $transferType');
                              //   });
                              // },
                            ),
                          ),
                        );
                      },
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
        DBPaivtItem()
            .createPaivtItem(Paivt(
          itemInvId: selectedInvtry,
          itemSerialNo: itemSNController.text,
        ))
            .then((value) {
          showSuccess('Item Save');
          Navigator.popUntil(
              context, ModalRoute.withName(StmsRoutes.paivtItemList));
        });
      } else {
        DBPaivtNonItem().getPaivtNonItem(selectedInvtry).then((value) {
          if (value == null) {
            DBPaivtNonItem()
                .createPaivtNonItem(PaivtNon(
              itemInvId: selectedInvtry,
              nonTracking: itemQtyController.text,
            ))
                .then((value) {
              showSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.paivtItemList));
            });
          } else {
            DBPaivtNonItem()
                .update(selectedInvtry, itemQtyController.text)
                .then((value) {
              showSuccess('Item Save');
              Navigator.popUntil(
                  context, ModalRoute.withName(StmsRoutes.paivtItemList));
            });
          }
        });
      }
    }
  }
}
