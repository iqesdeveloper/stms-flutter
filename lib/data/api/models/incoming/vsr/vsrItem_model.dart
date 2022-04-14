import 'dart:convert';

List<VsrItem> vsrItemFromJson(String str) =>
    List<VsrItem>.from(json.decode(str).map((x) => VsrItem.fromJson(x)));

String vsrItemToJson(List<VsrItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VsrItem {
  String itemIvId;
  String itemSn;
  // String itemReason;

  VsrItem({
    required this.itemIvId,
    required this.itemSn,
    // required this.itemReason,
  });

  factory VsrItem.fromJson(Map<String, dynamic> json) => VsrItem(
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
