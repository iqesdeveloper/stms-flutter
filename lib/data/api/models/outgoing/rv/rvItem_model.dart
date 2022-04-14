import 'dart:convert';

List<RvItem> rvItemFromJson(String str) =>
    List<RvItem>.from(json.decode(str).map((x) => RvItem.fromJson(x)));

String rvItemToJson(List<RvItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RvItem {
  String itemIvId;
  String itemSn;
  // String itemReason;

  RvItem({
    required this.itemIvId,
    required this.itemSn,
    // required this.itemReason,
  });

  factory RvItem.fromJson(Map<String, dynamic> json) => RvItem(
        itemIvId: json["item_inventory_id"],
        itemSn: json["item_serial_no"],
        // itemReason: json["item_reason_code"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemIvId,
        "item_serial_no": itemSn,
        // "item_reason_code": itemReason,
      };
}
