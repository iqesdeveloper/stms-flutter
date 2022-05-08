import 'package:flutter/material.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/repositories/api_json/api_out_paivt.dart';
import 'package:stms/data/local_db/outgoing/paivt/paivt_non_scanItem.dart';
import 'package:stms/data/local_db/outgoing/paivt/paivt_scanItem.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaivtDownloadView extends StatefulWidget {
  final Function changeView;

  const PaivtDownloadView({Key? key, required this.changeView})
      : super(key: key);

  @override
  _PaivtDownloadViewState createState() => _PaivtDownloadViewState();
}

class _PaivtDownloadViewState extends State<PaivtDownloadView> {
  var getPaivt = PaivtService();
  List locList = [];
  List paivtList = [];
  var selectedLoc, selectedPaivt;

  @override
  void initState() {
    super.initState();

    getPaivtList();
    removeListItem();
  }

  getPaivtList() {
    var token = Storage().token;
    getPaivt.getPaivtList(token).then((value) {
      setState(() {
        paivtList = value;
        paivtList.sort((a, b) => a["out_paiv_doc"]
            .toLowerCase()
            .compareTo(b["out_paiv_doc"].toLowerCase()));
        // print('paivt list value: $paivtList');
      });
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DBPaivtItem().deleteAllPaivtItem();
    DBPaivtNonItem().deleteAllPaivtNonItem();
    prefs.remove('paivt_info');
    prefs.remove('paivtLoc');
  }

  @override
  Widget build(BuildContext context) {
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
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText:
                                  'Please Choose Project Accounting IV File',
                              errorText:
                                  state.hasError ? state.errorText : null,
                            ),
                            isEmpty: false,
                            child: new DropdownButtonHideUnderline(
                              child: new DropdownButton<String>(
                                isDense: true,
                                iconSize: 28,
                                iconEnabledColor: Colors.amber,
                                items: paivtList.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(item['out_paiv_doc']),
                                    value: item['out_paiv_id'].toString(),
                                  );
                                }).toList(),
                                isExpanded: false,
                                value: selectedPaivt == "" ? "" : selectedPaivt,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedPaivt = newValue;
                                  });
                                },
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
              child: Container(
                height: MediaQuery.of(context).size.height*0.08,
                child: StmsStyleButton(
                  title: 'SELECT',
                  backgroundColor: Colors.amber,
                  textColor: Colors.black,
                  onPressed: () {
                    // Navigator.of(context)
                    //     .pushNamed(StmsRoutes.purchaseOrderItem);
                    savePaivt();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> savePaivt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('paivtID', selectedPaivt);
    removeListItem();

    PaivtService().getPaivtItem().then((value) {
      Navigator.of(context).pushNamed(StmsRoutes.paivtItemList).then((value) {
        setState(() {
          getPaivtList();
          selectedPaivt = null;
        });
      });
    });
  }
}
