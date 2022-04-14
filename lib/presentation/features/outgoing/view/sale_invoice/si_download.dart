import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/repositories/api_json/api_out_saleInvoice.dart';
import 'package:stms/data/local_db/master/master_customer_db.dart';
import 'package:stms/data/local_db/outgoing/si/si_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/si/si_scanItem.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SiDownloadView extends StatefulWidget {
  final Function changeView;

  const SiDownloadView({Key? key, required this.changeView}) : super(key: key);

  @override
  _SiDownloadViewState createState() => _SiDownloadViewState();
}

class _SiDownloadViewState extends State<SiDownloadView> {
  DateTime dateNow = DateTime.now();
  var getSaleInvoice = SaleInvoiceService();
  List locList = [];
  List custList = [];
  List siList = [];
  var formatDate, selectedLoc, selectedCust, selectedSi;
  final format = DateFormat("yyyy-MM-dd");

  final TextEditingController dateController = TextEditingController();
  final GlobalKey<StmsInputFieldState> dateKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    getCommon();
    // getSaleInvoiceList();
    removeListItem();
    // formatDate = DateFormat('yyyy-MM-dd').format(date);
  }

  getCommon() {
    DBMasterCustomer().getAllMasterCust().then((value) {
      print('value cust: $value');
      if (value == null) {
        ErrorDialog.showErrorDialog(
            context, 'Please download customer file at master page first');
      } else {
        setState(() {
          custList = value;
        });
      }
    });
  }

  getSaleInvoiceList(date) {
    // print('selected date: $date');
    var token = Storage().token;
    getSaleInvoice.getSiList(token).then((value) {
      setState(() {
        siList = value.where((w) => w['si_date'] == date).toList();
        // print('si list value: $siList');
        siList.sort((a, b) =>
            a["si_doc"].toLowerCase().compareTo(b["si_doc"].toLowerCase()));
      });
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBSaleInvoiceItem().deleteAllSiItem();
    DBSaleInvoiceNonItem().deleteAllSiNonItem();
    prefs.remove('si_info');
    prefs.remove('siLoc');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

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
              child: Column(
                children: [
                  Container(
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
                          child: DateTimeField(
                            format: format,
                            resetIcon: null,
                            key: dateKey,
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: 'Date',
                            ),
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? dateNow,
                                lastDate: DateTime(2200),
                              );

                              if (date != null) {
                                setState(() {
                                  // print(
                                  //     'select date: ${DateFormat('yyyy-MM-dd').format(date)}');
                                  selectedSi = null;
                                  getSaleInvoiceList(
                                      DateFormat('yyyy-MM-dd').format(date));
                                });
                              }

                              return date;
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
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
                              labelText: 'Please Choose Sales Invoice File',
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
                                  items: siList.map((item) {
                                    return new DropdownMenuItem(
                                      child: Container(
                                        width: width * 0.75,
                                        child: Row(
                                          children: [
                                            Text('${item['si_doc']} - '),
                                            Text(
                                              item['customer_name'],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      value: item['si_id'].toString(),
                                    );
                                  }).toList(),
                                  isExpanded: false,
                                  value: selectedSi == "" ? "" : selectedSi,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedSi = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                    onPressed: () {
                      // Navigator.of(context)
                      //     .pushNamed(StmsRoutes.purchaseOrderItem);
                      saveSi();
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

  Future<void> saveSi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('siID', selectedSi);
    removeListItem();

    SaleInvoiceService().getSiItem().then((value) {
      setState(() {
        dateController.text = '';
        selectedSi = null;
      });
      Navigator.of(context).pushNamed(StmsRoutes.siItemList);
    });
  }
}
