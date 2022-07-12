import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/paivt/paivt_non_model.dart';

class DBPaivtNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'paivtNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE paivtNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            ')');
      },
    );
  }

  // Insert PaivtItem on database
  Future<void> createPaivtNonItem(PaivtNon newPaivtNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'paivtNonItem',
      newPaivtNonItem.toJson(),
    );
  }

  // Delete all PaivtItem
  Future<int> deleteAllPaivtNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM paivtNonItem');

    return res;
  }

  // Delete selected PaivtNonItem
  Future<int> deletePaivtNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM paivtNonItem WHERE item_inventory_id == ?',
        [itemInvID]);

    return res;
  }

  // Get list of all PaivtItem
  Future<dynamic> getAllPaivtNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM paivtNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of certain PaivtItem
  Future<dynamic> getPaivtNonItem(String id) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM paivtNonItem WHERE item_inventory_id = ?", [id]);

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePaivtNonItem() async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM paivtNonItem WHERE item_serial_no != ?", ["-"]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM paivtNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }

  Future<dynamic> update(String id, String qty) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE paivtNonItem SET non_tracking_qty = ? WHERE item_inventory_id = ?',
        [qty, id]);
    return results;
  }
}
