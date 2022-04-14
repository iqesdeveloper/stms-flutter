import 'dart:convert';

List<PaivNonItem> paivNonItemFromJson(String str) => List<PaivNonItem>.from(
    json.decode(str).map((x) => PaivNonItem.fromJson(x)));

String paivNonItemToJson(List<PaivNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaivNonItem {
  // String? id;
  String itemInvId;
  String nonTracking;

  PaivNonItem({
    // this.id,
    required this.itemInvId,
    required this.nonTracking,
  });

  factory PaivNonItem.fromJson(Map<String, dynamic> json) => PaivNonItem(
        // id: json["id"],
        itemInvId: json["item_inventory_id"],
        nonTracking: json["non_tracking_qty"],
      );

  Map<String, dynamic> toJson() => {
        // "id": id,
        "item_inventory_id": itemInvId,
        "non_tracking_qty": nonTracking,
      };
}
