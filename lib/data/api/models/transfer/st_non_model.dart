import 'dart:convert';

List<StockTransNonItem> stockTransNonItemNonItemFromJson(String str) =>
    List<StockTransNonItem>.from(
        json.decode(str).map((x) => StockTransNonItem.fromJson(x)));

String stockTransNonItemNonItemToJson(List<StockTransNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StockTransNonItem {
  String itemIvId;
  String itemNonQty;
  String itemReason;

  StockTransNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    required this.itemReason,
  });

  factory StockTransNonItem.fromJson(Map<String, dynamic> json) =>
      StockTransNonItem(
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
