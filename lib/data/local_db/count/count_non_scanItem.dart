import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/count/count_non_model.dart';

class DBCountNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'countNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE countNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT,'
            'item_reason_code TEXT,'
            'item_location TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createCountNonItem(CountNonItem newCountNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'countNonItem',
      newCountNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllCountNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM countNonItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllCountNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM countNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain PoItem
  Future<dynamic> getCountNonItem(String id) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM countNonItem WHERE item_inventory_id = ?", [id]);

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodeCountItem() async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM countNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM countNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE countNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?',
        [qty, id]);
    return results;
  }
}
