import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/paiv/paiv_model.dart';

class DBPaivItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'paivItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE paivItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT'
            ')');
      },
    );
  }

  // Insert PaivItem on database
  Future<void> createPaivItem(PaivItem newPaivItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'paivItem',
      newPaivItem.toJson(),
    );
  }

  // Delete all PaivItem
  Future<int> deleteAllPaivItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM paivItem');

    return res;
  }

  // Get list of all PaivItem
  Future<dynamic> getAllPaivItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM paivItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get list of all barcode
  Future<dynamic> getBarcodePaivItem(invNo) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM paivItem WHERE item_serial_no != ? AND item_inventory_id == ?",
        ["-", invNo]);
    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Delete certain serial no
  Future<int> deletePaivItem(String itemSerial) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM paivItem WHERE item_serial_no == ?', [itemSerial]);

    return res;
  }

  // Delete certain item
  Future<int> deleteSelectedPaivItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM paivItem WHERE item_inventory_id == ?', [itemInvID]);

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM paivItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
