import 'dart:convert';

List<AdjustInItem> adjustInItemFromJson(String str) => List<AdjustInItem>.from(
    json.decode(str).map((x) => AdjustInItem.fromJson(x)));

String adjustInItemToJson(List<AdjustInItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjustInItem {
  String itemIvId;
  String itemSn;
  String itemReason;

  AdjustInItem({
    required this.itemIvId,
    required this.itemSn,
    required this.itemReason,
  });

  factory AdjustInItem.fromJson(Map<String, dynamic> json) => AdjustInItem(
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
