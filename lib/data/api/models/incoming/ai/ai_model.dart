import 'dart:convert';

List<AdjustIn> adjustInFromJson(String str) =>
    List<AdjustIn>.from(json.decode(str).map((x) => AdjustIn.fromJson(x)));

String adjustInToJson(List<AdjustIn> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdjustIn {
  String iaTxnType;
  String iaDate;
  String location;

  AdjustIn({
    required this.iaTxnType,
    required this.iaDate,
    required this.location,
  });

  factory AdjustIn.fromJson(Map<String, dynamic> json) => AdjustIn(
        iaTxnType: json["transaction_type"],
        iaDate: json["ia_date"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_type": iaTxnType,
        "ia_date": iaDate,
        "location": location,
      };
}
