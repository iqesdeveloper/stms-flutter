import 'dart:convert';

List<ItemModifyNonItem> itemModifyNonItemFromJson(String str) =>
    List<ItemModifyNonItem>.from(
        json.decode(str).map((x) => ItemModifyNonItem.fromJson(x)));

String itemModifyNonItemToJson(List<ItemModifyNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemModifyNonItem {
  String itemIvId;
  String itemNonQty;
  String itemReason;

  ItemModifyNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    required this.itemReason,
  });

  factory ItemModifyNonItem.fromJson(Map<String, dynamic> json) =>
      ItemModifyNonItem(
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
