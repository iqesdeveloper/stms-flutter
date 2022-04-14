import 'dart:convert';

List<ReturnVendor> returnVendorFromJson(String str) => List<ReturnVendor>.from(
    json.decode(str).map((x) => ReturnVendor.fromJson(x)));

String returnVendorToJson(List<ReturnVendor> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReturnVendor {
  String rvDate;
  String txnType;
  String crDoc;
  String rvVendor;
  String rvLocation;

  ReturnVendor({
    required this.rvDate,
    required this.txnType,
    required this.crDoc,
    required this.rvVendor,
    required this.rvLocation,
  });

  factory ReturnVendor.fromJson(Map<String, dynamic> json) => ReturnVendor(
        rvDate: json["rs_date"],
        txnType: json["transaction_type"],
        crDoc: json["out_rs_doc"],
        rvVendor: json["supplier_id"],
        rvLocation: json["location_id"],
      );

  Map<String, dynamic> toJson() => {
        "rs_date": rvDate,
        "transaction_type": txnType,
        "out_rs_doc": crDoc,
        "supplier_id": rvVendor,
        "location_id": rvLocation,
      };
}
