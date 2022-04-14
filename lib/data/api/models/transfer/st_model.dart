import 'dart:convert';

List<StockTransfer> stockTransferFromJson(String str) =>
    List<StockTransfer>.from(
        json.decode(str).map((x) => StockTransfer.fromJson(x)));

String stockTransferToJson(List<StockTransfer> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StockTransfer {
  String stiDate;
  String stType;
  String transOutDoc;
  String toLoc;
  String fromLoc;

  StockTransfer({
    required this.stiDate,
    required this.stType,
    required this.transOutDoc,
    required this.toLoc,
    required this.fromLoc,
  });

  factory StockTransfer.fromJson(Map<String, dynamic> json) => StockTransfer(
        stiDate: json["sti_date"],
        stType: json["sti_type"],
        transOutDoc: json["transfer_out_document"],
        toLoc: json["to_location"],
        fromLoc: json["from_location"],
      );

  Map<String, dynamic> toJson() => {
        "sti_date": stiDate,
        "sti_type": stType,
        "transfer_out_document": transOutDoc,
        "to_location": toLoc,
        "from_location": fromLoc,
      };
}
