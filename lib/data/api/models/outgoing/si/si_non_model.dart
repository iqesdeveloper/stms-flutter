import 'dart:convert';

List<SaleInvoiceNon> saleInvoiceNonItemFromJson(String str) =>
    List<SaleInvoiceNon>.from(
        json.decode(str).map((x) => SaleInvoiceNon.fromJson(x)));

String saleInvoiceNonItemToJson(List<SaleInvoiceNon> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SaleInvoiceNon {
  String itemInvId;
  String nonTracking;

  SaleInvoiceNon({
    required this.itemInvId,
    required this.nonTracking,
  });

  factory SaleInvoiceNon.fromJson(Map<String, dynamic> json) => SaleInvoiceNon(
        itemInvId: json["item_inventory_id"],
        nonTracking: json["non_tracking_qty"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "non_tracking_qty": nonTracking,
      };
}
