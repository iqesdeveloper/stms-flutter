import 'dart:convert';

List<RricItem> rricItemFromJson(String str) =>
    List<RricItem>.from(json.decode(str).map((x) => RricItem.fromJson(x)));

String rricItemToJson(List<RricItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RricItem {
  String itemIvId;
  String itemSn;
  // String itemReason;

  RricItem({
    required this.itemIvId,
    required this.itemSn,
    // required this.itemReason,
  });

  factory RricItem.fromJson(Map<String, dynamic> json) => RricItem(
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
