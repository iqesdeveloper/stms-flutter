import 'dart:convert';

List<CustRetItem> custRetItemFromJson(String str) => List<CustRetItem>.from(
    json.decode(str).map((x) => CustRetItem.fromJson(x)));

String custRetItemToJson(List<CustRetItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustRetItem {
  String itemIvId;
  String itemSn;
  // String itemReason;

  CustRetItem({
    required this.itemIvId,
    required this.itemSn,
    // required this.itemReason,
  });

  factory CustRetItem.fromJson(Map<String, dynamic> json) => CustRetItem(
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
