import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/im/imItem_model.dart';

class DBItemModifyItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'imItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE imItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT,'
            'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createImItem(ItemModifyItem newImItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'imItem',
      newImItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllImItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM imItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteImItem(String itemInvID, String itemSerialNo, String itemReasonCode) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM imItem WHERE item_inventory_id == ? AND item_serial_no == ? AND item_reason_code == ?',
        [itemInvID, itemSerialNo, itemReasonCode]);

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllImItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM imItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM imItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
