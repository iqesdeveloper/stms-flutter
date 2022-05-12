import 'dart:convert';

List<PoNonItem> poNonItemFromJson(String str) =>
    List<PoNonItem>.from(json.decode(str).map((x) => PoNonItem.fromJson(x)));

String poNonItemToJson(List<PoNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class for Purchase Order scan data collected
// So whenever the item is scan, it will store this data
class PoNonItem {
  String itemInvId;
  String vendorItemName;
  String nonTracking;

  PoNonItem({
    // this.id,
    required this.itemInvId,
    required this.vendorItemName,
    required this.nonTracking,
  });

  factory PoNonItem.fromJson(Map<String, dynamic> json) => PoNonItem(
        // id: json["id"],
        itemInvId: json["item_inventory_id"],
        vendorItemName: json["vendor_item_number"],
        nonTracking: json["non_tracking_qty"],
      );

  Map<String, dynamic> toJson() => {
        // "id": id,
        "item_inventory_id": itemInvId,
        "vendor_item_number": vendorItemName,
        "non_tracking_qty": nonTracking,
      };
}
