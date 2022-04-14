import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/transfer/st_non_model.dart';

class DBStockTransNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'stNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE stNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT,'
            'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createStNonItem(StockTransNonItem newStNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'stNonItem',
      newStNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllStNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM stNonItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteStNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM stNonItem WHERE item_inventory_id == ?', [itemInvID]);

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllStNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM stNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM stNonItem ');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
