import 'dart:convert';

List<StockTransItem> stockTransItemFromJson(String str) =>
    List<StockTransItem>.from(
        json.decode(str).map((x) => StockTransItem.fromJson(x)));

String stockTransItemToJson(List<StockTransItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StockTransItem {
  String itemIvId;
  String itemSn;
  String itemReason;

  StockTransItem({
    required this.itemIvId,
    required this.itemSn,
    required this.itemReason,
  });

  factory StockTransItem.fromJson(Map<String, dynamic> json) => StockTransItem(
        itemIvId: json["item_inventory_id"],
        itemSn: json["item_serial_no"],
        itemReason: json["item_reason_code"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemIvId,
        "item_serial_no": itemSn,
        "item_reason_code": itemReason,
      };
}
