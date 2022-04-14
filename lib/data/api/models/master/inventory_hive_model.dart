import 'dart:convert';

import 'package:hive/hive.dart';

part 'inventory_hive_model.g.dart';

List<InventoryHive> inventoryHiveFromJson(String str) =>
    List<InventoryHive>.from(
        json.decode(str).map((x) => InventoryHive.fromJson(x)));

String inventoryHiveToJson(List<InventoryHive> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 1)
class InventoryHive {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String type;
  @HiveField(3)
  var upc;
  @HiveField(4)
  String sku;

  InventoryHive({
    required this.id,
    required this.name,
    required this.type,
    required this.sku,
    required this.upc,
  });

  factory InventoryHive.fromJson(Map<String, dynamic> json) => InventoryHive(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        upc: json["upc"],
        sku: json["sku"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "upc": upc,
        "sku": sku,
      };
}
