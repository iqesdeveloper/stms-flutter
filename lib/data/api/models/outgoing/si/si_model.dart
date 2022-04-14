import 'dart:convert';

List<SaleInvoice> saleInvoiceItemFromJson(String str) => List<SaleInvoice>.from(
    json.decode(str).map((x) => SaleInvoice.fromJson(x)));

String saleInvoiceItemToJson(List<SaleInvoice> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SaleInvoice {
  String itemInvId;
  String itemSerialNo;

  SaleInvoice({
    required this.itemInvId,
    required this.itemSerialNo,
  });

  factory SaleInvoice.fromJson(Map<String, dynamic> json) => SaleInvoice(
        itemInvId: json["item_inventory_id"],
        itemSerialNo: json["item_serial_no"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "item_serial_no": itemSerialNo,
      };
}
