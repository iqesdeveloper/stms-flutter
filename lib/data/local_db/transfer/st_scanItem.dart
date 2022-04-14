import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/transfer/stItem_model.dart';

class DBStockTransItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'stItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE stItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT,'
            'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createStItem(StockTransItem newStItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'stItem',
      newStItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllStItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM stItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteStItem(String itemInvID, String itemSerialNo) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM stItem WHERE item_inventory_id == ?  AND item_serial_no == ?',
        [itemInvID, itemSerialNo]);

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllStItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM stItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM stItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
