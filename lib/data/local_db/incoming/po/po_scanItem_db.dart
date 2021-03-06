import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/po/po_model.dart';

class DBPoItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'poItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE poItem('
            'item_inventory_id TEXT,'
            'vendor_item_number TEXT,'
            'line_seq_no TEXT,'
            'item_serial_no TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createPoItem(PoItem newPoItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'poItem',
      newPoItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllPoItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM poItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllPoItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM poItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePoItem(invNo, lineSeqNo) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM poItem WHERE item_serial_no != ? AND item_inventory_id == ?  "
            "AND line_seq_no = ?",
        ["-", invNo, lineSeqNo]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Delete certain serial no
  Future<int> deletePoItem(String itemSerial) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM poItem WHERE item_serial_no == ?', [itemSerial]);

    return res;
  }

  // Delete certain item
  Future<int> deleteSelectedPoItem(String itemInvID, String itemLineSeq) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM poItem WHERE item_inventory_id == ? AND line_seq_no ==?', [itemInvID, itemLineSeq]);

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM poItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  // // Get data in []
  // Future<dynamic> getUpload() async {
  //   final db = await database;
  //   var results = await db.rawQuery(
  //       'SELECT item_inventory_id, vendor_item_number, item_serial_no FROM poItem'
  //   );
  //   if (results.length > 0) {
  //     return results;
  //   }
  //
  //   return null;
  // }
}
