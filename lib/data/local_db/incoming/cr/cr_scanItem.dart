import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/incoming/cr/crItem_model.dart';

class DBCustReturnItem {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'crItem.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE crItem('
            'item_inventory_id TEXT,'
            'item_serial_no TEXT'
            // 'item_reason_code TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createCrItem(CustRetItem newCrItem) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'crItem',
      newCrItem.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllCrItem() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM crItem');

    return res;
  }

  // Delete certain serial no
  Future<int> deleteCrItem(String itemInvID, String itemSerialNo) async {
    final db = await database;
    final res = await db.rawDelete(
        'DELETE FROM crItem WHERE item_inventory_id == ? AND item_serial_no == ?',
        [itemInvID, itemSerialNo]);

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllCrItem() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM crItem");

    if (res.length > 0) {
      return res;
    }

    return null;
  }

  // Get data in []
  Future<dynamic> getUpload() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM crItem');
    if (results.length > 0) {
      return results;
    }

    return null;
  }
}
