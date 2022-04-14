import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/outgoing/rv/rvItem_model.dart';

class DBReturnVendorItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'rvItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE rvItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT'
            // 'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createRvItem(RvItem newRvItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'rvItem',
      newRvItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllRvItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM rvItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteRvItem(String itemInvID, String itemSerialNo) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM rvItem WHERE item_inventory_id == ? AND item_serial_no == ?',
        [itemInvID, itemSerialNo]);

    return res;
  }

  // Get list of all PoItem
  Future<List<Map<String, dynamic>>> getAllRvItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM rvItem");

    if (res.length > 0) {
      return res;
    }

    return res;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM rvItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
