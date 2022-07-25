import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/po/po_non_model.dart';

class DBPoNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'poNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE poNonItem('
            'item_inventory_id TEXT,'
            'vendor_item_number TEXT,'
            'line_seq_no TEXT,'
            'non_tracking_qty TEXT'
            ')');
      },
    );
  }

  // Insert PoNonItem on database
  Future<void> createPoNonItem(PoNonItem newPoNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'poNonItem',
      newPoNonItem.toJson(),
    );
  }

  // Delete all PoNonItem
  Future<int> deleteAllPoNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM poNonItem');

    return res;
  }

  // Delete selected PoNonItem
  Future<int> deletePoNonItem(String itemInvID, String itemLineSeq) async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM poNonItem WHERE item_inventory_id == ? '
        'AND line_seq_no ==?',
        [itemInvID, itemLineSeq]);

    return res;
  }

  // Get list of all PoNonItem
  Future<dynamic> getAllPoNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM poNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain PoItem
  Future<dynamic> getPoNonItem(String id, String lineSeqNo) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM poNonItem WHERE item_inventory_id = ? "
        "AND line_seq_no = ?", [id, lineSeqNo] );

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePoNonItem() async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM poNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // // Get data in []
  // Future<dynamic> getUpload() async {
  //   final db = await database;
  //   var results = await db.rawQuery(
  //       'SELECT item_inventory_id, vendor_item_number, non_tracking_qty FROM poNonItem'
  //   );
  //   if (results.length > 0) {
  //     return results;
  //   }
  //
  //   return null;
  // }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM poNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty, String lineSeqNo) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE poNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?  '
            'AND line_seq_no = ?',
        [qty, id, lineSeqNo]);
    return results;
  }
}
