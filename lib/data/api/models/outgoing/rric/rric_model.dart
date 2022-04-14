import 'dart:convert';

List<ReplaceCust> replaceCustFromJson(String str) => List<ReplaceCust>.from(
    json.decode(str).map((x) => ReplaceCust.fromJson(x)));

String replaceCustToJson(List<ReplaceCust> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReplaceCust {
  String rcDate;
  String txnType;
  String vsrDoc;
  String rcCust;
  String rcLocation;
  String crDoc;

  ReplaceCust({
    required this.rcDate,
    required this.txnType,
    required this.vsrDoc,
    required this.rcCust,
    required this.rcLocation,
    required this.crDoc,
  });

  factory ReplaceCust.fromJson(Map<String, dynamic> json) => ReplaceCust(
        rcDate: json["rc_date"],
        txnType: json["transaction_type"],
        vsrDoc: json["vsr_doc_no"],
        rcCust: json["customer_id"],
        rcLocation: json["location_id"],
        crDoc: json["cr_doc_no"],
      );

  Map<String, dynamic> toJson() => {
        "rc_date": rcDate,
        "transaction_type": txnType,
        "vsr_doc_no": vsrDoc,
        "customer_id": rcCust,
        "location_id": rcLocation,
        "cr_doc_no": crDoc,
      };
}
