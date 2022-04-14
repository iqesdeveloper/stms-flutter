import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/count/count_model.dart';

class DBCountItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'countItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE countItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT,'
            'item_reason_code TEXT,'
            'item_location TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createCountItem(CountItem newCountItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'countItem',
      newCountItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllCountItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM countItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllCountItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM countItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodeCountItem(String invNo) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM countItem WHERE item_serial_no != ? AND item_inventory_id == ?",
        ["-", invNo]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM countItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
