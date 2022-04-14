import 'dart:convert';

List<CustRetNonItem> custRetNonItemFromJson(String str) =>
    List<CustRetNonItem>.from(
        json.decode(str).map((x) => CustRetNonItem.fromJson(x)));

String custRetNonItemToJson(List<CustRetNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustRetNonItem {
  String itemIvId;
  String itemNonQty;
  // String itemReason;

  CustRetNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    // required this.itemReason,
  });

  factory CustRetNonItem.fromJson(Map<String, dynamic> json) => CustRetNonItem(
        itemIvId: json["item_inventory_id"],
        itemNonQty: json["non_tracking_qty"],
        // itemReason: json["item_reason_code"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemIvId,
        "non_tracking_qty": itemNonQty,
        // "item_reason_code": itemReason,
      };
}
