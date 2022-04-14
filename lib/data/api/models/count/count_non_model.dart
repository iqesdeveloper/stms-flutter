import 'dart:convert';

List<CountNonItem> countNonItemFromJson(String str) => List<CountNonItem>.from(
    json.decode(str).map((x) => CountNonItem.fromJson(x)));

String countNonItemToJson(List<CountNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CountNonItem {
  String itemInvId;
  String nonTracking;
  String itemReason;
  String itemLocation;

  CountNonItem({
    required this.itemInvId,
    required this.nonTracking,
    required this.itemReason,
    required this.itemLocation,
  });

  factory CountNonItem.fromJson(Map<String, dynamic> json) => CountNonItem(
        itemInvId: json["item_inventory_id"],
        nonTracking: json["non_tracking_qty"],
        itemReason: json["item_reason_code"],
        itemLocation: json["item_location"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "non_tracking_qty": nonTracking,
        "item_reason_code": itemReason,
        "item_location": itemLocation,
      };
}
