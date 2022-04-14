import 'dart:convert';

// Location
List<Location> locationFromJson(String str) =>
    List<Location>.from(json.decode(str).map((x) => Location.fromJson(x)));

String locationToJson(List<Location> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Location {
  String id;
  String name;

  Location({
    required this.id,
    required this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

// Reject Reason
List<RejectReason> rejectReasonFromJson(String str) => List<RejectReason>.from(
    json.decode(str).map((x) => RejectReason.fromJson(x)));

String rejectReasonToJson(List<RejectReason> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RejectReason {
  String id;
  String code;
  String desc;

  RejectReason({
    required this.id,
    required this.code,
    required this.desc,
  });

  factory RejectReason.fromJson(Map<String, dynamic> json) => RejectReason(
        id: json["id"],
        code: json["code"],
        desc: json["desc"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "desc": desc,
      };
}

// Status
List<Status> statusFromJson(String str) =>
    List<Status>.from(json.decode(str).map((x) => Status.fromJson(x)));

String statusToJson(List<Status> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Status {
  String id;
  String name;

  Status({
    required this.id,
    required this.name,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

// Customer
List<Customer> customerFromJson(String str) =>
    List<Customer>.from(json.decode(str).map((x) => Customer.fromJson(x)));

String customerToJson(List<Customer> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Customer {
  String id;
  String name;

  Customer({
    required this.id,
    required this.name,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

// Supplier
List<Supplier> supplierFromJson(String str) =>
    List<Supplier>.from(json.decode(str).map((x) => Supplier.fromJson(x)));

String supplierToJson(List<Supplier> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Supplier {
  String id;
  String name;

  Supplier({
    required this.id,
    required this.name,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

//  Inventory
List<Inventory> inventoryFromJson(String str) =>
    List<Inventory>.from(json.decode(str).map((x) => Inventory.fromJson(x)));

String inventoryToJson(List<Inventory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Inventory {
  String id;
  String name;
  String type;
  var upc;
  String sku;

  Inventory({
    required this.id,
    required this.name,
    required this.type,
    required this.upc,
    required this.sku,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        upc: json["upc"],
        sku: json["sku"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "upc": upc,
        "sku": sku,
      };
}
