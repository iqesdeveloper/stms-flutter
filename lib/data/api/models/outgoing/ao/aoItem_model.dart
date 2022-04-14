import 'dart:convert';

List<AdjustOutItem> adjustOutItemFromJson(String str) =>
    List<AdjustOutItem>.from(
        json.decode(str).map((x) => AdjustOutItem.fromJson(x)));

String adjustOutItemToJson(List<AdjustOutItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjustOutItem {
  String itemIvId;
  String itemSn;
  String itemReason;

  AdjustOutItem({
    required this.itemIvId,
    required this.itemSn,
    required this.itemReason,
  });

  factory AdjustOutItem.fromJson(Map<String, dynamic> json) => AdjustOutItem(
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
