import 'dart:convert';

List<PaivItem> paivItemFromJson(String str) =>
    List<PaivItem>.from(json.decode(str).map((x) => PaivItem.fromJson(x)));

String paivItemToJson(List<PaivItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaivItem {
  // String? id;
  String itemInvId;
  String itemSerialNo;

  PaivItem({
    // this.id,
    required this.itemInvId,
    required this.itemSerialNo,
  });

  factory PaivItem.fromJson(Map<String, dynamic> json) => PaivItem(
        // id: json["id"],
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
      );

  Map<String, dynamic> toJson() => {
        // "id": id,
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
      };
}
