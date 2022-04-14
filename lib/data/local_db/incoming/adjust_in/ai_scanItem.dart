import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/ai/aiItem_model.dart';

class DBAdjustInItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'aiItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE aiItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT,'
            'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createAiItem(AdjustInItem newAiItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'aiItem',
      newAiItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllAiItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM aiItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteAiItem(String itemInvID, String itemSerialNo) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM aiItem WHERE item_inventory_id == ? AND item_serial_no == ?',
        [itemInvID, itemSerialNo]);

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllAiItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM aiItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM aiItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
