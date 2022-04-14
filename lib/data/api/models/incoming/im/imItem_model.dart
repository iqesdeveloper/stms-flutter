import 'dart:convert';

List<ItemModifyItem> itemModifyItemFromJson(String str) =>
    List<ItemModifyItem>.from(
        json.decode(str).map((x) => ItemModifyItem.fromJson(x)));

String itemModifyItemToJson(List<ItemModifyItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemModifyItem {
  String itemIvId;
  String itemSn;
  String itemReason;

  ItemModifyItem({
    required this.itemIvId,
    required this.itemSn,
    required this.itemReason,
  });

  factory ItemModifyItem.fromJson(Map<String, dynamic> json) => ItemModifyItem(
        itemIvId: json["item_inventory_id"],
        itemSn: json["item_serial_no"],
        itemReason: json["item_reason_code"],
      );

  Map<String, dynamic> toJson() => {
        "item_inventory_id": itemIvId,
        "item_serial_no": itemSn,
        "item_reason_code": itemReason,
      };
}
