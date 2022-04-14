import 'dart:convert';

List<ItemModify> itemModifyFromJson(String str) =>
    List<ItemModify>.from(json.decode(str).map((x) => ItemModify.fromJson(x)));

String itemModifyToJson(List<ItemModify> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemModify {
  String imTxnType;
  String imDate;
  String location;

  ItemModify({
    required this.imTxnType,
    required this.imDate,
    required this.location,
  });

  factory ItemModify.fromJson(Map<String, dynamic> json) => ItemModify(
        imTxnType: json["transaction_type"],
        imDate: json["im_date"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_type": imTxnType,
        "im_date": imDate,
        "location": location,
      };
}
