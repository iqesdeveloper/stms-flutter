import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stms/data/api/models/master/master_model.dart';

class DBMasterInventory {
  static Database? _database;
  // static final DBMasterInventory db = DBMasterInventory._();

  // DBMasterInventory._();

  // Future<Database> get database async {
  //   // If database exists, return database
  //   if (_database != null) return _database;

  //   // If database don't exists, create one
  //   _database = await initDB();

  //   return _database;
  // }
  Future<Database> get database async => _database ??= await initDB();

  // Create the database and the customer table
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'masterInv.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE masterInv('
            'id TEXT,'
            'name TEXT,'
            'type TEXT,'
            'upc TEXT,'
            'sku TEXT'
            ')');
      },
    );
  }

  // Insert PoItem on database
  Future createMasterInv(Inventory newInventory) async {
    final db = await database;
    await db.transaction((txn) async {
      var batch = txn.batch();

      batch.insert('masterInv', newInventory.toJson());

      // commit but the actual commit will happen when the transaction is committed
      // however the data is available in this transaction
      await batch.commit(noResult: true);
      await batch.commit(continueOnError: true);

      //  ...
    });

    db.close();

    // Get a reference to the database.
    // final db = await database;
    // await db.insert(
    //   'masterInv',
    //   newInventory.toJson(),
    // );

    // final db = await database;
    // Batch batch = db.batch();
    // final res = batch.insert('masterInv', newInventory.toJson());

    // await batch.commit();
    // return res;

    // Batch batch = db.batch();
    // batch.insert('masterInv', newInventory.toJson());
    // return res;
    // for (int i = 0; i < 100; i++) {
    //   batch.insert(
    //     'masterInv',
    //     newInventory.toJson(),
    //   );
    // }

    // await batch.commit();
  }

  // Delete all PoItem
  Future<int> deleteAllMasterInv() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM masterInv');

    return res;
  }

  // Get list of all PoItem
  Future<dynamic> getAllMasterInv() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM masterInv");

    if (res.length > 0) {
      return res;
    }

    return null;
  }
}
