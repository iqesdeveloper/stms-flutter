import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/master/master_model.dart';

class DBMasterLocation {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'masterLoc.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE masterLoc('
            'id TEXT,'
            'name TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createMasterLoc(Location newLocation) async {
    // Get a reference to the database.
    final db = await database;
    Batch batch = db.batch();

    batch.insert(
      'masterLoc',
      newLocation.toJson(),
    );
    batch.commit();

    // final db = await database;
    // await db.insert(
    //   'masterLoc',
    //   newLocation.toJson(),
    // );
  }

  // Delete all PoItem
  Future<int> deleteAllMasterLoc() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM masterLoc');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllMasterLoc() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM masterLoc");

    if (res.length > 0) {
      return res;
    }

    return null;
  }
}
