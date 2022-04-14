import 'dart:convert';

List<AdjustInNonItem> adjustInNonItemFromJson(String str) =>
    List<AdjustInNonItem>.from(
        json.decode(str).map((x) => AdjustInNonItem.fromJson(x)));

String adjustInNonItemToJson(List<AdjustInNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjustInNonItem {
  String itemIvId;
  String itemNonQty;
  String itemReason;

  AdjustInNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    required this.itemReason,
  });

  factory AdjustInNonItem.fromJson(Map<String, dynamic> json) =>
      AdjustInNonItem(
        itemIvId: json["item_inventory_id"],
        itemNonQty: json["non_tracking_qty"],
        itemReason: json["item_reason_code"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemIvId,
        "non_tracking_qty": itemNonQty,
        "item_reason_code": itemReason,
      };
}
