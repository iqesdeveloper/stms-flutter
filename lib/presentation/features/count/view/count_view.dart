import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stms/data/api/models/count/count_download_model.dart';
import 'package:stms/data/api/repositories/api_json/api_count.dart';
// import 'package:stms/data/local_db/count/count.dart';
import 'package:stms/data/local_db/count/count_non_scanItem.dart';
import 'package:stms/data/local_db/count/count_scanItem.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';

class CountView extends StatefulWidget {
  final Function changeView;

  const CountView({Key? key, required this.changeView}) : super(key: key);

  @override
  _CountViewState createState() => _CountViewState();
}

class _CountViewState extends State<CountView> {
  List countList = [];
  List<dynamic> _stockList = [];
  List<dynamic> get stockList => _stockList;
  var selectedCount;
  var getStockCount = CountService();
  // final HiveService hiveService = HiveService();

  @override
  void initState() {
    super.initState();

    getCountList();
    removeListItem();
  }

  getCountList() {
    var token = Storage().token;
    getStockCount.getcountList(token).then((value) {
      if (value == []) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          countList = value;
          print('count list value: $countList');
        });
      }
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBCountItem().deleteAllCountItem();
    DBCountNonItem().deleteAllCountNonItem();

    prefs.remove('countId_info');
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Form(
                // key: _key,
                // ignore: deprecated_member_use
                // autovalidate: _validate,
                child: Container(
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText:
                                'Please Choose Stock Count File to Download',
                            errorText: state.hasError ? state.errorText : null,
                          ),
                          isEmpty: false,
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              isDense: true,
                              iconSize: 28,
                              iconEnabledColor: Colors.amber,
                              items: countList.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(
                                    item['sc_doc'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: item['sc_id'].toString(),
                                );
                              }).toList(),
                              isExpanded: false,
                              value: selectedCount == "" ? "" : selectedCount,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCount = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
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
                    title: 'SELECT',
                    backgroundColor: Colors.amber,
                    textColor: Colors.black,
                    onPressed: () async {
                      // Navigator.of(context)
                      //     .pushNamed(StmsRoutes.purchaseOrderItem);
                      // await Hive.openBox('stock_box');
                      saveCountFile(selectedCount);
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveCountFile(String? selectedCount) async {
    if (selectedCount == null) {
      ErrorDialog.showErrorDialog(context, 'Please select Stock Count file');
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('countID', selectedCount);
      removeListItem();

      // var result = await CountService().getCountItem();
      // (result).map((e) {
      //   StockCount stock = StockCount(
      //     itemInvId: e['item_inventory_id'],
      //     itemName: e['item_name'],
      //     itemReason: e['item_reason_code'],
      //     itemLoc: e['item_location'],
      //     itemLocName: e['item_location_name'],
      //     trackingType: e['tracking_type'],
      //     itemReceiveQty: e['item_receive_qty'],
      //   );
      //   _stockList.add(stock);
      // }).toList();
      // await hiveService.addBoxes(_stockList, "StockTable");
      // Navigator.of(context).pushNamed(StmsRoutes.countItemList);

      CountService().getCountItem().then((value) {
        //   (value as List).map((e) {
        //     StockCount stock = StockCount(
        //       itemInvId: e['item_inventory_id'],
        //       itemName: e['item_name'],
        //       itemReason: e['item_reason_code'],
        //       itemLoc: e['item_location'],
        //       itemLocName: e['item_location_name'],
        //       trackingType: e['tracking_type'],
        //       itemReceiveQty: e['item_receive_qty'],
        //     );
        //     _stockList.add(stock);
        //   }).toList();

        //   await hiveService.addBoxes(_stockList, "StockTable");
        Navigator.of(context).pushNamed(StmsRoutes.countItemList);
      });
    }
  }
}
