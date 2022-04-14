import 'dart:convert';

List<VendorReplace> vendorReplaceFromJson(String str) =>
    List<VendorReplace>.from(
        json.decode(str).map((x) => VendorReplace.fromJson(x)));

String vendorReplaceToJson(List<VendorReplace> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VendorReplace {
  String vsrDate;
  String returnDoc;
  String vsrVendor;
  String vsrLoc;

  VendorReplace({
    required this.vsrDate,
    required this.returnDoc,
    required this.vsrVendor,
    required this.vsrLoc,
  });

  factory VendorReplace.fromJson(Map<String, dynamic> json) => VendorReplace(
        vsrDate: json["rs_date"],
        returnDoc: json["return_supplier_transaction_id"],
        vsrVendor: json["supplier_id"],
        vsrLoc: json['location'],
      );

  Map<String, dynamic> toJson() => {
        "rs_date": vsrDate,
        "return_supplier_transaction_id": returnDoc,
        "supplier_id": vsrVendor,
        "location_id": vsrLoc,
      };
}
