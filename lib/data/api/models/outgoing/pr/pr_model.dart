import 'dart:convert';

List<PurchaseReturn> purchaseReturnItemFromJson(String str) =>
    List<PurchaseReturn>.from(
        json.decode(str).map((x) => PurchaseReturn.fromJson(x)));

String purchaseReturnItemToJson(List<PurchaseReturn> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PurchaseReturn {
  String itemInvId;
  String itemSerialNo;

  PurchaseReturn({
    required this.itemInvId,
    required this.itemSerialNo,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) => PurchaseReturn(
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
      };
}
