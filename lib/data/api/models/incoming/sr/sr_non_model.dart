import 'dart:convert';

List<SaleReturnNon> saleReturnNonItemFromJson(String str) =>
    List<SaleReturnNon>.from(
        json.decode(str).map((x) => SaleReturnNon.fromJson(x)));

String saleReturnNonItemToJson(List<SaleReturnNon> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SaleReturnNon {
  String itemInvId;
  String nonTracking;

  SaleReturnNon({
    required this.itemInvId,
    required this.nonTracking,
  });

  factory SaleReturnNon.fromJson(Map<String, dynamic> json) => SaleReturnNon(
        itemInvId: json["item_inventory_id"],
        nonTracking: json["non_tracking_qty"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "non_tracking_qty": nonTracking,
      };
}
