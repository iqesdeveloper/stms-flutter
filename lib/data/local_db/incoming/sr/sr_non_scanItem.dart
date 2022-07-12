import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/sr/sr_non_model.dart';

class DBSaleReturnNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'srNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE srNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            ')');
      },
    );
  }

  // Insert SrItem on database
  Future<void> createSrNonItem(SaleReturnNon newSrNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'srNonItem',
      newSrNonItem.toJson(),
    );
  }

  // Delete all srNonItem
  Future<int> deleteAllSrNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM srNonItem');

    return res;
  }

  // Delete selected SrNonItem
  Future<int> deleteSrNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM SrNonItem WHERE item_inventory_id == ?',
        [itemInvID]);

    return res;
  }

  // Get list of all srNonItem
  Future<dynamic> getAllSrNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM srNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain SrItem
  Future<dynamic> getSrNonItem(String id) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM srNonItem WHERE item_inventory_id = ?", [id]);

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodeSrNonItem() async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM srNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM srNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE srNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?',
        [qty, id]);
    return results;
  }
}
