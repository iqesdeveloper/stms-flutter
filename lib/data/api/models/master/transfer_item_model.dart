import 'dart:convert';

List<TransferItem> transferItemFromJson(String str) => List<TransferItem>.from(
    json.decode(str).map((x) => TransferItem.fromJson(x)));

String transferItemToJson(List<TransferItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransferItem {
  var id;
  String? inventoryCode;
  String? reasonCode;
  String? serialNo;
  String? fromLoc;
  String? toLoc;

  TransferItem({
    this.id,
    required this.inventoryCode,
    required this.reasonCode,
    required this.serialNo,
    required this.fromLoc,
    required this.toLoc,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) => TransferItem(
        id: json["id"],
        inventoryCode: json["inventoryCode"],
        reasonCode: json["reasonCode"],
        serialNo: json["serialNo"],
        fromLoc: json["fromLoc"],
        toLoc: json["toLoc"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "inventoryCode": inventoryCode,
        "reasonCode": reasonCode,
        "serialNo": serialNo,
        "fromLoc": fromLoc,
        "toLoc": toLoc,
      };
}
