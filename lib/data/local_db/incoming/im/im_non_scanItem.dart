import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/im/im_non_model.dart';

class DBItemModifyNonItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'imNonItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE imNonItem('
            'item_inventory_id TEXT,'
            'non_tracking_qty TEXT,'
            'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createImNonItem(ItemModifyNonItem newImNonItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'imNonItem',
      newImNonItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllImNonItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM imNonItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteImNonItem(String itemInvID, String itemReasonCode) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM imNonItem WHERE item_inventory_id == ? AND item_reason_code == ?',
        [itemInvID, itemReasonCode]);

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllImNonItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM imNonItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM imNonItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
