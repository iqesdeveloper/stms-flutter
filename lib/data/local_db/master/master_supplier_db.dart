import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/master/master_model.dart';

class DBMasterSupplier {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'masterSupplier.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE masterSupplier('
            'id TEXT,'
            'name TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createMasterSupplier(Supplier newSupplier) async {
    // Get a reference to the database.
    // final db = await database;
    // await db.insert(
    //   'masterSupplier',
    //   newSupplier.toJson(),
    // );
    final db = await database;
    Batch batch = db.batch();

    batch.insert(
      'masterSupplier',
      newSupplier.toJson(),
    );
    batch.commit();
  }

  // Delete all PoItem
  Future<int> deleteAllMasterSupplier() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM masterSupplier');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllMasterSupplier() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM masterSupplier");

    if (res.length > 0) {
      return res;
    }

    return null;
  }
}
