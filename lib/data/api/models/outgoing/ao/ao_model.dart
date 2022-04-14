import 'dart:convert';

List<AdjustOut> adjustOutFromJson(String str) =>
    List<AdjustOut>.from(json.decode(str).map((x) => AdjustOut.fromJson(x)));

String adjustOutToJson(List<AdjustOut> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjustOut {
  String aoTxnType;
  String aoDate;
  String location;

  AdjustOut({
    required this.aoTxnType,
    required this.aoDate,
    required this.location,
  });

  factory AdjustOut.fromJson(Map<String, dynamic> json) => AdjustOut(
        aoTxnType: json["transaction_type"],
        aoDate: json["out_ia_date"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_type": aoTxnType,
        "out_ia_date": aoDate,
        "location": location,
      };
}
