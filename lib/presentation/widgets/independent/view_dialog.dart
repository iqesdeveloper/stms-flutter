import 'package:flutter/material.dart';
import 'package:stms/data/local_db/incoming/paiv/paiv_scanItem_db.dart';
import 'package:stms/data/local_db/incoming/po/po_scanItem_db.dart';
import 'package:stms/data/local_db/incoming/sr/sr_scanItem_db.dart';
import 'package:stms/data/local_db/outgoing/paivt/paivt_scanItem.dart';
import 'package:stms/data/local_db/outgoing/pr/pr_scanItem.dart';
import 'package:stms/data/local_db/outgoing/si/si_scanItem.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class ViewDialog extends StatelessWidget {
  final urlList;
  final db;

  const ViewDialog({
    Key? key,
    required this.urlList,
    required this.db,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      height: height * 0.01, // * 0.25,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: width,
            height: height * 0.05,
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scanned QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 2),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                // padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(color: Colors.black, width: 1),
                  columnWidths: const <int, TableColumnWidth>{
                    1: FixedColumnWidth(70.0),
                  },
                  children: [
                    TableRow(
                      children: [
                        Container(
                          height: 35,
                          alignment: Alignment.center,
                          child: Text(
                            'Serial No',
                            style: TextStyle(
                              fontSize: 16.0,
                              // height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          ' ',
                          style: TextStyle(
                            fontSize: 16.0,
                            // height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: FutureBuilder(
                  future: urlList,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Material(
                            // color: index % 2 == 0 ? Colors.white : Colors.grey[400],
                            child: Table(
                              border: TableBorder.all(
                                color: Colors.black,
                                width: 0.2,
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              columnWidths: const <int, TableColumnWidth>{
                                1: FixedColumnWidth(70.0),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                                      child: Text(
                                        "${snapshot.data[index]['item_serial_no']}",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          // height: 2.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          // print('pressed');
                                          getDB(
                                              context,
                                              snapshot.data[index]
                                                  ['item_serial_no']);
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  getDB(BuildContext context, String serialNo) {
    print('serial: $serialNo');
    if (db == 'DBPoItem') {
      DBPoItem().deletePoItem(serialNo).then((value) {
        if (value == 1) {
          showSuccess('Delete Successful');
          Navigator.pop(context);
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else if (db == 'DBPaivItem') {
      DBPaivItem().deletePaivItem(serialNo).then((value) {
        if (value == 1) {
          showSuccess('Delete Successful');
          Navigator.pop(context);
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else if (db == 'DBSaleReturnItem') {
      DBSaleReturnItem().deleteSrItem(serialNo).then((value) {
        if (value == 1) {
          showSuccess('Delete Successful');
          Navigator.pop(context);
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else if (db == 'DBSaleInvoiceItem') {
      DBSaleInvoiceItem().deleteSiItem(serialNo).then((value) {
        if (value == 1) {
          showSuccess('Delete Successful');
          Navigator.pop(context);
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else if (db == 'DBPaivtItem') {
      DBPaivtItem().deletePaivtItem(serialNo).then((value) {
        if (value == 1) {
          showSuccess('Delete Successful');
          Navigator.pop(context);
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    } else if (db == 'DBPurchaseReturnItem') {
      DBPurchaseReturnItem().deletePrItem(serialNo).then((value) {
        if (value == 1) {
          showSuccess('Delete Successful');
          Navigator.pop(context);
        } else {
          ErrorDialog.showErrorDialog(context, 'Unsuccessful Delete!');
        }
      });
    }
  }

  static Future showViewDialog(BuildContext context, var listUrl, var getDb) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: ViewDialog(
            urlList: listUrl,
            db: getDb,
          ),
        );
      },
    );
  }
}
