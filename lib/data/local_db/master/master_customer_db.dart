import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/master/master_model.dart';

class DBMasterCustomer {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'masterCust.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE masterCust('
            'id TEXT,'
            'name TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future<void> createMasterCust(Customer newCustomer) async {
    // Get a reference to the database.
    // final db = await database;
    // await db.insert(
    //   'masterCust',
    //   newCustomer.toJson(),
    // );

    final db = await database;
    Batch batch = db.batch();

    batch.insert(
      'masterCust',
      newCustomer.toJson(),
    );
    batch.commit();
  }

  // Future<int> updateMasterCust(Customer newcust) async {
  //   final db = await database;
  //   // final res = await db.update('masterCust', newcust.toJson());
  //   final res = await db.rawUpdate('UPDATE masterCust SET ..');

  //   return res;
  // }

  // Delete all PoItem
  Future<int> deleteAllMasterCust() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM masterCust');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllMasterCust() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM masterCust");

    if (res.length > 0) {
      return res;
    }

    return null;
  }
}
