import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/pr/pr_non_model.dart';

class DBPurchaseReturnNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'prNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE prNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createPrNonItem(PurchaseReturnNon newPrNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'prNonItem',
      newPrNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllPrNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM prNonItem');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllPrNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM prNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain PoItem
  Future<dynamic> getPrNonItem(String id) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM prNonItem WHERE item_inventory_id = ?", [id]);

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePrNonItem() async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM prNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM prNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE prNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?',
        [qty, id]);
    return results;
  }
}
