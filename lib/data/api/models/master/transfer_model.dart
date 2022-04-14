import 'dart:convert';

List<Transfer> transferFromJson(String str) =>
    List<Transfer>.from(json.decode(str).map((x) => Transfer.fromJson(x)));

String transferToJson(List<Transfer> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Transfer {
  var id;
  String? transferDocNo;
  String? stiType;
  String? stiBatch;
  String? status;
  String? rejectReason;
  String? receiveDate;
  String? shipDate;
  String? custName;

  Transfer({
    required this.id,
    required this.transferDocNo,
    required this.stiType,
    required this.stiBatch,
    required this.status,
    required this.rejectReason,
    required this.receiveDate,
    required this.shipDate,
    required this.custName,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) => Transfer(
        id: json["id"],
        transferDocNo: json['transferDocNo'],
        stiType: json["stiType"],
        stiBatch: json["stiBatch"],
        status: json["status"],
        rejectReason: json["rejectReason"],
        receiveDate: json["receiveDate"],
        shipDate: json["shipDate"],
        custName: json["custName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "transferDocNo": transferDocNo,
        "stiType": stiType,
        "stiBatch": stiBatch,
        "status": status,
        "rejectReason": rejectReason,
        "receiveDate": receiveDate,
        "shipDate": shipDate,
        "custName": custName,
      };
}
