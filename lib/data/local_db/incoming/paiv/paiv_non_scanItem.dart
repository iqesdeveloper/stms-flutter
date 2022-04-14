import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/paiv/paiv_non_model.dart';

class DBPaivNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'paivNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE paivNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createPaivNonItem(PaivNonItem newPaivNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'paivNonItem',
      newPaivNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllPaivNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM paivNonItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllPaivNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM paivNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain PoItem
  Future<dynamic> getPaivNonItem(String id) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM paivNonItem WHERE item_inventory_id = ?", [id]);

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePaivItem() async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM paivNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM paivNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE paivNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?',
        [qty, id]);
    return results;
  }

  // Future<dynamic> getQty(String id) async {
  //   print('id: $id');
  //   final db = await database;
  //   final res = await db.rawQuery(
  //       "SELECT * FROM paivNonItem WHERE item_inventory_id == ?", [id]);
  //   return res;
  // }

  // Future getTotal(String id) async {
  //   print('id: $id');
  //   final db = await database;
  //   var result = await db.rawQuery(
  //       "SELECT SUM(non_tracking_qty) as Total FROM paivNonItem WHERE item_inventory_id == ?",
  //       [id]);
  //   int? count = Sqflite.firstIntValue(
  //       await db.rawQuery('SELECT COUNT(non_tracking_qty) FROM paivNonItem'));
  //   // int value = int.parse(result[0]["SUM(non_tracking_qty)"]); // value = 220
  //   return count;
  // }

  // Future getDataJan(String id) async {
  //   final db = await database;
  //   var sumJan = await db.rawQuery(
  //       'SELECT SUM(non_tracking_qty) FROM paivNonItem WHERE item_inventory_id == ?',
  //       [id]).then(Sqflite.firstIntValue);
  //   print(sumJan);
  //   return sumJan.toString();
  // }
}
