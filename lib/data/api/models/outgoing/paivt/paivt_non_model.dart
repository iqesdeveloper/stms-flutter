import 'dart:convert';

List<PaivtNon> paivtNonItemFromJson(String str) =>
    List<PaivtNon>.from(json.decode(str).map((x) => PaivtNon.fromJson(x)));

String paivtNonItemToJson(List<PaivtNon> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaivtNon {
  String itemInvId;
  String nonTracking;

  PaivtNon({
    required this.itemInvId,
    required this.nonTracking,
  });

  factory PaivtNon.fromJson(Map<String, dynamic> json) => PaivtNon(
        itemInvId: json["item_inventory_id"],
        nonTracking: json["non_tracking_qty"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemInvId,
        "non_tracking_qty": nonTracking,
      };
}
