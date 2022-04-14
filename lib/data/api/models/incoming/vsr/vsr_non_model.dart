import 'dart:convert';

List<VsrNonItem> vsrNonItemFromJson(String str) =>
    List<VsrNonItem>.from(json.decode(str).map((x) => VsrNonItem.fromJson(x)));

String vsrNonItemToJson(List<VsrNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VsrNonItem {
  String itemIvId;
  String itemNonQty;
  // String itemReason;

  VsrNonItem({
    required this.itemIvId,
    required this.itemNonQty,
    // required this.itemReason,
  });

  factory VsrNonItem.fromJson(Map<String, dynamic> json) => VsrNonItem(
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
