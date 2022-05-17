import 'dart:convert';

List<PoItem> poItemFromJson(String str) =>
    List<PoItem>.from(json.decode(str).map((x) => PoItem.fromJson(x)));

String poItemToJson(List<PoItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class for Purchase Order scan data collected
// So whenever the item is scan, it will store this data
class PoItem {
  // Add variable to represent the data store when scan
  String itemInvId;
  String vendorItemNo;
  String itemSerialNo;

  PoItem({
    required this.itemInvId,
    required this.vendorItemNo,
    required this.itemSerialNo,
  });

  factory PoItem.fromJson(Map<String, dynamic> json) => PoItem(
    itemInvId: json["item_inventory_id"],
    vendorItemNo: json["vendor_item_number"],
    itemSerialNo: json["item_serial_no"],
  );

  Map<String, dynamic> toJson() => {
    "item_inventory_id": itemInvId,
    "vendor_item_number": vendorItemNo,
    "item_serial_no": itemSerialNo,
  };
}

