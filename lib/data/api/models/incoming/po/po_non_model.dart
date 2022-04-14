import 'dart:convert';

List<PoNonItem> poNonItemFromJson(String str) =>
    List<PoNonItem>.from(json.decode(str).map((x) => PoNonItem.fromJson(x)));

String poNonItemToJson(List<PoNonItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PoNonItem {
  String itemInvId;
  String nonTracking;

  PoNonItem({
    // this.id,
    required this.itemInvId,
    required this.nonTracking,
  });

  factory PoNonItem.fromJson(Map<String, dynamic> json) => PoNonItem(
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
