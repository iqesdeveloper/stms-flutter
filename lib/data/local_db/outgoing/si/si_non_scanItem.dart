import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/si/si_non_model.dart';

class DBSaleInvoiceNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'siNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE siNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            ')');
      },
    );
  }

  // Insert SiItem on database
  Future<void> createSiNonItem(SaleInvoiceNon newSiNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'siNonItem',
      newSiNonItem.toJson(),
    );
  }

  // Delete all SiItem
  Future<int> deleteAllSiNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM siNonItem');

    return res;
  }

  // Delete selected SiNonItem
  Future<int> deleteSiNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM SiNonItem WHERE item_inventory_id == ?',
        [itemInvID]);

    return res;
  }

  // Get list of all SiItem
  Future<dynamic> getAllSiNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM siNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain SiItem
  Future<dynamic> getSiNonItem(String id) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM siNonItem WHERE item_inventory_id = ?", [id]);

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodeSiNonItem() async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM siNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM siNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE siNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?',
        [qty, id]);
    return results;
  }
}
