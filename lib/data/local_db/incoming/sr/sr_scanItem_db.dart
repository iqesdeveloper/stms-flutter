import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/sr/sr_model.dart';

class DBSaleReturnItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'srItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE srItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createSrItem(SaleReturn newSrItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'srItem',
      newSrItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllSrItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM srItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllSrItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM srItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodeSrItem(String invNo) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM srItem WHERE item_serial_no != ? AND item_inventory_id == ?",
        ["-", invNo]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Delete certain serial no
  Future<int> deleteSrItem(String itemSerial) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM srItem WHERE item_serial_no == ?', [itemSerial]);

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM srItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
