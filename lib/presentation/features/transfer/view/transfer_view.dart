import 'package:flutter/material.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/data/local_db/transfer/st_non_scanItem.dart';
import 'package:stms/data/local_db/transfer/st_scanItem.dart';

class TransferView extends StatefulWidget {
  final Function changeView;

  const TransferView({Key? key, required this.changeView}) : super(key: key);

  @override
  _TransferViewState createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: MaterialButton(
              onPressed: () {
                String transferType = '1';
                selectTransfer(transferType);
                // Navigator.of(context).pushNamed(StmsRoutes.transferIn);
              },
              child: Container(
                height: height * 0.2,
                width: width * 0.4,
                color: Colors.amber,
                alignment: Alignment.center,
                child: Text(
                  'IN',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.05),
          Container(
            alignment: Alignment.center,
            child: MaterialButton(
              onPressed: () {
                String transferType = '2';
                selectTransfer(transferType);
              },
              child: Container(
                height: height * 0.2,
                width: width * 0.4,
                color: Colors.amber,
                alignment: Alignment.center,
                child: Text(
                  'OUT',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// write to keystore/keychain
  Future<void> selectTransfer(String transferType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Storage()
        .secureStorage
        .write(key: 'transferType', value: transferType);
    Storage().transfer = transferType;

    DBStockTransItem().deleteAllStItem();
    DBStockTransNonItem().deleteAllStNonItem();
    await prefs.remove('barcode_scan');
    prefs.remove('saveST');

    // widget.changeView(changeType: ViewChangeType.Forward);
    Navigator.of(context).pushNamed(StmsRoutes.transfer);
  }
}
