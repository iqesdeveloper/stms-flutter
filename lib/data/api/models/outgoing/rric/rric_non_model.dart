import 'dart:convert';

List<RricNonItem> rricNonItemFromJson(String str) => List<RricNonItem>.from(
    json.decode(str).map((x) => RricNonItem.fromJson(x)));

String rricNonItemToJson(List<RricNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RricNonItem {
  String itemIvId;
  String itemNonQty;
  // String itemReason;

  RricNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    // required this.itemReason,
  });

  factory RricNonItem.fromJson(Map<String, dynamic> json) => RricNonItem(
        itemIvId: json["item_inventory_id"],
        itemNonQty: json["non_tracking_qty"],
        // itemReason: json["item_reason_code"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemIvId,
        "non_tracking_qty": itemNonQty,
        // "item_reason_code": itemReason,
      };
}
