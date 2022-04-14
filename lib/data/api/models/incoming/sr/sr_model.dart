import 'dart:convert';

List<SaleReturn> saleReturnItemFromJson(String str) =>
    List<SaleReturn>.from(json.decode(str).map((x) => SaleReturn.fromJson(x)));

String saleReturnItemToJson(List<SaleReturn> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SaleReturn {
  String itemInvId;
  String itemSerialNo;

  SaleReturn({
    required this.itemInvId,
    required this.itemSerialNo,
  });

  factory SaleReturn.fromJson(Map<String, dynamic> json) => SaleReturn(
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
      };
}
