import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/master/master_model.dart';

class DBMasterReason {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'masterReason.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE masterReason('
            'id TEXT,'
            'code TEXT,'
            'desc TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createMasterReason(RejectReason newReason) async {
    // Get a reference to the database.
    final db = await database;
    await db.insert(
      'masterReason',
      newReason.toJson(),
    );
  }

  // Delete all PoItem
  Future<int> deleteAllMasterReason() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM masterReason');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllMasterReason() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM masterReason");

    if (res.length > 0) {
      return res;
    }

    return null;
  }
}
