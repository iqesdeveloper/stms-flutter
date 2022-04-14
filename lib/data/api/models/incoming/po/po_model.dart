import 'dart:convert';

List<PoItem> poItemFromJson(String str) =>
    List<PoItem>.from(json.decode(str).map((x) => PoItem.fromJson(x)));

String poItemToJson(List<PoItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PoItem {
  String itemInvId;
  String itemSerialNo;

  PoItem({
    required this.itemInvId,
    required this.itemSerialNo,
  });

  factory PoItem.fromJson(Map<String, dynamic> json) => PoItem(
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
      };
}
