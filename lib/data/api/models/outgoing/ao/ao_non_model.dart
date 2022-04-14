import 'dart:convert';

List<AdjustOutNonItem> adjustOutNonItemFromJson(String str) =>
    List<AdjustOutNonItem>.from(
        json.decode(str).map((x) => AdjustOutNonItem.fromJson(x)));

String adjustOutNonItemToJson(List<AdjustOutNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjustOutNonItem {
  String itemIvId;
  String itemNonQty;
  String itemReason;

  AdjustOutNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    required this.itemReason,
  });

  factory AdjustOutNonItem.fromJson(Map<String, dynamic> json) =>
      AdjustOutNonItem(
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
