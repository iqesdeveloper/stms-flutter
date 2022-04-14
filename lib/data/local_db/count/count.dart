import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:stms/data/api/models/count/count_model.dart';
import 'package:stms/data/api/models/count/stock_list.dart';

class DBStockList {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'stockList.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE countItem('
            'item_inventory_id TEXT,'
            'item_name TEXT,'
            'item_reason_code TEXT,'
            'item_location TEXT,'
            'item_location_name TEXT,'
            'tracking_type TEXT,'
            'item_receive_qty TEXT'
            ')');
      },
    );
  }

  // // Insert PoItem on database
  // Future<void> createCountItem(CountItem newCountItem) async {
  //   // Get a reference to the database.
  //   final db = await database;
  //   await db.insert(
  //     'countItem',
  //     newCountItem.toJson(),
  //   );
  // }

  batchInsertStock(StockList newCountItem) async {
    final db = await database;
    db.transaction((txn) async {
      Batch batch = txn.batch();
      // for (var stock in newCountItem) {
      // StockCount stock = StockCount(
      // itemInvId: e['item_inventory_id'],
      // itemName: e['item_name'],
      // itemReason: e['item_reason_code'],
      // itemLoc: e['item_location'],
      // itemLocName: e['item_location_name'],
      // trackingType: e['tracking_type'],
      // itemReceiveQty: e['item_receive_qty'],
      // );
      // Map<String, dynamic> row = {
      //   columnIt: stock.itemInvId,
      //   DatabaseHelper.columnTitle: stock.itemName,
      //   DatabaseHelper.columnInterpreter: stock.itemReason
      // };
      batch.insert('countItem', newCountItem.toJson());
      // }
      batch.commit();
    });
  }

  // // Delete all PoItem
  // Future<int> deleteAllCountItem() async {
  //   final db = await database;
  //   final res = await db.rawDelete('DELETE FROM countItem');

  //   return res;
  // }

  // // Get list of all PoItem
  // Future<dynamic> getAllCountItem() async {
  //   final db = await database;
  //   final res = await db.rawQuery("SELECT * FROM countItem");

  //   if (res.length > 0) {
  //     return res;
  //   }

  //   return null;
  // }

  // // Get list of all barcode
  // Future<dynamic> getBarcodeCountItem(String invNo) async {
  //   final db = await database;
  //   final res = await db.rawQuery(
  //       "SELECT * FROM countItem WHERE item_serial_no != ? AND item_inventory_id == ?",
  //       ["-", invNo]);
  //   if (res.length > 0) {
  //     return res;
  //   }

  //   return null;
  // }

  // // Get data in []
  // Future<dynamic> getUpload() async {
  //   final db = await database;
  //   var results = await db.rawQuery('SELECT * FROM countItem');
  //   if (results.length > 0) {
  //     return results;
  //   }

  //   return null;
  // }
}


// import 'package:hive/hive.dart';

// class HiveService {
//   isExists({required String boxName}) async {
//     final openBox = await Hive.openBox(boxName);
//     int length = openBox.length;
//     return length != 0;
//   }

//   addBoxes<T>(List<T> items, String boxName) async {
//     print("adding boxes");
//     final openBox = await Hive.openBox(boxName);

//     for (var item in items) {
//       openBox.add(item);
//     }
//   }

//   getBoxes<T>(String boxName) async {
//     List<T> boxList = [];

//     final openBox = await Hive.openBox(boxName);

//     int length = openBox.length;

//     for (int i = 0; i < length; i++) {
//       boxList.add(openBox.getAt(i));
//     }
//   }
// }
