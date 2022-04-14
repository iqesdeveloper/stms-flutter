import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/cr/cr_non_model.dart';

class DBCustReturnNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'crNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE crNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT'
            // 'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createCrNonItem(CustRetNonItem newCrNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'crNonItem',
      newCrNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllCrNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM crNonItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteCrNonItem(String itemInvID) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM crNonItem WHERE item_inventory_id == ?', [itemInvID]);

    return res;
  }

  // Get list of all PoItem
  Future<List<Map<String, dynamic>>> getAllCrNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM crNonItem");

    if (res.length > 0) {
      return res;
    }

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM crNonItem ');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
