import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/vsr/vsr_non_model.dart';

class DBVendorReplaceNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'vsrNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE vsrNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            // 'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createVsrNonItem(VsrNonItem newVsrNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'vsrNonItem',
      newVsrNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllVsrNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM vsrNonItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteVsrNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM vsrNonItem WHERE item_inventory_id == ?', [itemInvID]);

    return res;
  }

  // Get list of all PoItem
  Future<List<Map<String, dynamic>>> getAllVsrNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM vsrNonItem");

    if (res.length > 0) {
      return res;
    }

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM vsrNonItem ');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
