import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';

class DBMasterInventoryHive {
  final _masterInventory = Hive.box<InventoryHive>('inventory');

  // Create new item
  Future createItem(InventoryHive newItem) async {
    await _masterInventory.add(
      InventoryHive(
        id: newItem.id,
        name: newItem.name,
        type: newItem.type,
        sku: newItem.sku,
        upc: newItem.upc,
      ),
    );
    // await _masterInventory.putAll(entries)
    // await _masterInventory.put(
    //   "",
    //   InventoryHive(
    //     id: newItem.id,
    //     name: newItem.name,
    //     type: newItem.type,
    //     sku: newItem.sku,
    //     upc: newItem.upc,
    //   ),
    // );
  }

  // Future<dynamic>
  Future getAllInvHive() async {
    // final db = await database;
    // final res = await db.rawQuery("SELECT * FROM masterInv");
    final item = _masterInventory.values.toList();

    if (item.length > 0) {
      return item;
    } else {
      return null;
    }
  }

  Future<List<dynamic>> getHiveInv() async {
    // var box = await Hive.openBox(boxName);

    List<dynamic> inventoryHive = _masterInventory.values.toList();

    return inventoryHive;
  }

  // Update a single item
  // Future<void> updateItem(int itemKey, Map<String, dynamic> item) async {
  //   await _masterInventory.put(itemKey, item);
  //   // _refreshItems(); // Update the UI
  // }

  // Delete a single item
  Future<void> deleteItem() async {
    await _masterInventory.clear();
    // _refreshItems(); // update the UI

    // // Display a snackbar
    // ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('An item has been deleted')));
  }
}
