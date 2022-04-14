// import 'dart:convert';

// import 'package:hive/hive.dart';

// part 'count_download_model.g.dart';

// List<StockCount> stockCountFromJson(String str) =>
//     List<StockCount>.from(json.decode(str).map((x) => StockCount.fromJson(x)));

// String stockCountToJson(List<StockCount> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// @HiveType(typeId: 0)
// class StockCount extends HiveObject {
//   @HiveField(0)
//   final String itemInvId;
//   @HiveField(1)
//   final String itemName;
//   @HiveField(2)
//   final String itemReason;
//   @HiveField(3)
//   final String itemLoc;
//   @HiveField(4)
//   final String itemLocName;
//   @HiveField(5)
//   final String trackingType;
//   @HiveField(6)
//   final String itemReceiveQty;

//   StockCount({
//     required this.itemInvId,
//     required this.itemName,
//     required this.itemReason,
//     required this.itemLoc,
//     required this.itemLocName,
//     required this.trackingType,
//     required this.itemReceiveQty,
//   });

//   factory StockCount.fromJson(Map<String, dynamic> json) => StockCount(
//         itemInvId: json["item_inventory_id"],
//         itemName: json["item_name"],
//         itemReason: json["item_reason_code"],
//         itemLoc: json["item_location"],
//         itemLocName: json["item_location_name"],
//         trackingType: json["tracking_type"],
//         itemReceiveQty: json["item_receive_qty"],
//       );

//   Map<String, dynamic> toJson() => {
//         "item_inventory_id": itemInvId,
//         "item_name": itemName,
//         "item_reason_code": itemReason,
//         "item_location": itemLoc,
//         "item_location_name": itemLocName,
//         "tracking_type": trackingType,
//         "item_receive_qty": itemReceiveQty,
//       };
// }
