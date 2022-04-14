import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/rric/rricItem_model.dart';

class DBReplaceCustItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'rricItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE rricItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT'
            // 'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createRricItem(RricItem newRricItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'rricItem',
      newRricItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllRricItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM rricItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteRricItem(String itemInvID, String itemSerialNo) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM rricItem WHERE item_inventory_id == ? AND item_serial_no == ?',
        [itemInvID, itemSerialNo]);

    return res;
  }

  // Get list of all PoItem
  Future<List<Map<String, dynamic>>> getAllRricItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM rricItem");

    if (res.length > 0) {
      return res;
    }

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM rricItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
