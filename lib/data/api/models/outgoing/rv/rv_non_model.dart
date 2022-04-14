import 'dart:convert';

List<RvNonItem> rvNonItemFromJson(String str) =>
    List<RvNonItem>.from(json.decode(str).map((x) => RvNonItem.fromJson(x)));

String rvNonItemToJson(List<RvNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RvNonItem {
  String itemIvId;
  String itemNonQty;
  // String itemReason;

  RvNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    // required this.itemReason,
  });

  factory RvNonItem.fromJson(Map<String, dynamic> json) => RvNonItem(
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
