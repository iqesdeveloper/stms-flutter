import 'dart:convert';

List<PurchaseReturnNon> purchaseReturnNonItemFromJson(String str) =>
    List<PurchaseReturnNon>.from(
        json.decode(str).map((x) => PurchaseReturnNon.fromJson(x)));

String purchaseReturnNonItemToJson(List<PurchaseReturnNon> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PurchaseReturnNon {
  String itemInvId;
  String nonTracking;

  PurchaseReturnNon({
    required this.itemInvId,
    required this.nonTracking,
  });

  factory PurchaseReturnNon.fromJson(Map<String, dynamic> json) =>
      PurchaseReturnNon(
        itemInvId: json["item_inventory_id"],
        nonTracking: json["non_tracking_qty"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "non_tracking_qty": nonTracking,
      };
}
