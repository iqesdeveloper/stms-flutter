import 'package:flutter/material.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/repositories/api_json/api_in_paiv.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_non_scanItem.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_scanItem_db.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaivDownloadView extends StatefulWidget {
  final Function changeView;

  const PaivDownloadView({Key? key, required this.changeView})
      : super(key: key);

  @override
  _PaivDownloadViewState createState() => _PaivDownloadViewState();
}

class _PaivDownloadViewState extends State<PaivDownloadView> {
  var getPaiv = PaivService();
  List locList = [];
  List paivList = [];
  var selectedLoc, selectedPaiv;

  @override
  void initState() {
    super.initState();

    getPaivList();
    removeListItem();
  }

  getPaivList() {
    var token = Storage().token;
    getPaiv.getPaivList(token).then((value) {
      if (value.length == 0) {
        ErrorDialog.showErrorDialog(context, 'No File to Download');
      } else {
        setState(() {
          paivList = value;
          paivList.sort((a, b) => a["paiv_trdn"]
              .toLowerCase()
              .compareTo(b["paiv_trdn"].toLowerCase()));
          print('paiv list value: $paivList');
        });
      }
    });
  }

  removeListItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBPaivItem().deleteAllPaivItem();
    DBPaivNonItem().deleteAllPaivNonItem();

    prefs.remove('paiv_info');
    prefs.remove('paivLoc');
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
                              child: ButtonTheme(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  iconSize: 28,
                                  iconEnabledColor: Colors.amber,
                                  items: paivList.map((item) {
                                    return new DropdownMenuItem(
                                      child: new Text(
                                        item['paiv_trdn'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      value: item['paiv_id'].toString(),
                                    );
                                  }).toList(),
                                  isExpanded: false,
                                  value: selectedPaiv == "" ? "" : selectedPaiv,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedPaiv = newValue;
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
                      savePaiv();
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

  Future<void> savePaiv() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('paivID', selectedPaiv!);
    removeListItem();

    PaivService().getPaivItem().then((value) {
      Navigator.of(context).pushNamed(StmsRoutes.paivItemList).then((value) {
        setState(() {
          selectedPaiv = null;
          getPaivList();
        });
      });
    });
  }
}
