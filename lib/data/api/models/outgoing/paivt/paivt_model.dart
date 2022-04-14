import 'dart:convert';

List<Paivt> paivtItemFromJson(String str) =>
    List<Paivt>.from(json.decode(str).map((x) => Paivt.fromJson(x)));

String paivtItemToJson(List<Paivt> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Paivt {
  String itemInvId;
  String itemSerialNo;

  Paivt({
    required this.itemInvId,
    required this.itemSerialNo,
  });

  factory Paivt.fromJson(Map<String, dynamic> json) => Paivt(
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
      };
}
