import 'dart:convert';

List<StockList> stockListFromJson(String str) =>
    List<StockList>.from(json.decode(str).map((x) => StockList.fromJson(x)));

String stockListToJson(List<StockList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StockList {
  String itemInvId;
  String itemName;
  String itemReason;
  String itemLocation;
  String itemLocName;
  String trackingType;
  String itemReceiveQty;

  StockList({
    required this.itemInvId,
    required this.itemName,
    required this.itemReason,
    required this.itemLocation,
    required this.itemLocName,
    required this.trackingType,
    required this.itemReceiveQty,
  });

  factory StockList.fromJson(Map<String, dynamic> json) => StockList(
        itemInvId: json["item_inventory_id"],
        itemName: json["item_name"],
        itemReason: json["item_reason_code"],
        itemLocation: json["item_location"],
        itemLocName: json["item_location_name"],
        trackingType: json["tracking_type"],
        itemReceiveQty: json["item_receive_qty"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_name": itemName,
        "item_reason_code": itemReason,
        "item_location": itemLocation,
        "item_location_name": itemLocName,
        "tracking_type": trackingType,
        "item_receive_qty": itemReceiveQty,
      };
}
