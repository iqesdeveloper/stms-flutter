import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/pr/pr_model.dart';

class DBPurchaseReturnItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'prItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE prItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createPrItem(PurchaseReturn newPrItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'prItem',
      newPrItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllPrItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM prItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllPrItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM prItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePrItem(invNo) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM prItem WHERE item_serial_no != ? AND item_inventory_id == ?",
        ["-", invNo]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Delete certain serial no
  Future<int> deletePrItem(String itemSerial) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM prItem WHERE item_serial_no == ?', [itemSerial]);

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM prItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
