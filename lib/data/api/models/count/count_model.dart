import 'dart:convert';

List<CountItem> countItemFromJson(String str) =>
    List<CountItem>.from(json.decode(str).map((x) => CountItem.fromJson(x)));

String countItemToJson(List<CountItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CountItem {
  String itemInvId;
  String itemSerialNo;
  String itemReason;
  String itemLocation;

  CountItem({
    required this.itemInvId,
    required this.itemSerialNo,
    required this.itemReason,
    required this.itemLocation,
  });

  factory CountItem.fromJson(Map<String, dynamic> json) => CountItem(
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
        itemReason: json["item_reason_code"],
        itemLocation: json["item_location"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
        "item_reason_code": itemReason,
        "item_location": itemLocation,
      };
}
