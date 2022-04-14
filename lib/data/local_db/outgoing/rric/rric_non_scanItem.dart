import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/rric/rric_non_model.dart';

class DBReplaceCustNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'rricNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE rricNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            // 'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createRricNonItem(RricNonItem newRricNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'rricNonItem',
      newRricNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllRricNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM rricNonItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteRricNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM rricNonItem WHERE item_inventory_id == ?', [itemInvID]);

    return res;
  }

  // Get list of all PoItem
  Future<List<Map<String, dynamic>>> getAllRricNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM rricNonItem");
    //   // Query the table for all The Dogs.
    // final List<Map<String, dynamic>> maps = await db.query('dogs');
    if (res.length > 0) {
      return res;
    }

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM rricNonItem ');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
