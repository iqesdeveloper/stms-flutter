import 'dart:convert';

List<CustReturn> custReturnFromJson(String str) =>
    List<CustReturn>.from(json.decode(str).map((x) => CustReturn.fromJson(x)));

String custReturnToJson(List<CustReturn> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustReturn {
  String crDate;
  String crCustomer;
  String crLoc;

  CustReturn({
    required this.crDate,
    required this.crCustomer,
    required this.crLoc,
  });

  factory CustReturn.fromJson(Map<String, dynamic> json) => CustReturn(
        crDate: json["rc_date"],
        crCustomer: json["customer_id"],
        crLoc: json["location_id"],
      );

  Map<String, dynamic> toJson() => {
        "rc_date": crDate,
        "customer_id": crCustomer,
        "location_id": crLoc,
      };
}
