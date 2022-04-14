import 'dart:convert';
import 'dart:io';

import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/master/inventory_hive_model.dart';
import 'package:stms/data/api/models/master/master_model.dart';
import 'package:stms/data/error/exceptions.dart';
import 'package:stms/data/local_db/master/master_customer_db.dart';
import 'package:stms/data/local_db/master/master_inventory_hive_db.dart';
import 'package:stms/data/local_db/master/master_location_db.dart';
import 'package:stms/data/local_db/master/master_reason_db.dart';
import 'package:stms/data/local_db/master/master_supplier_db.dart';

class CommonService {
  Future<List<dynamic>> getLocation() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String getLocUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.getLocation;

    var queryParameters = {
      'token': Storage().token,
    };
    var uri = Uri.parse(getLocUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String datasection = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(datasection.toString());
    print('value db loc: ${jsonResponse['data']}');

    List<dynamic> list = [];
    if (jsonResponse['data'] != null) {
      list =
          jsonResponse['data'].map((item) => Location.fromJson(item)).toList();

      for (int i = 0; i < list.length; i++) {
        final locItem = jsonResponse['data'][i];
        final id = locItem['id'];
        final name = locItem['name'];
        DBMasterLocation().getAllMasterLoc().then((value) {
          print('value db loc: $value');
          if (value != null) {
            DBMasterLocation().deleteAllMasterLoc().then((value) {
              DBMasterLocation().createMasterLoc(Location(id: id, name: name));
            });
          } else {
            DBMasterLocation().createMasterLoc(Location(id: id, name: name));
          }
        });
      }
    }
    return list;
  }

  Future<List<dynamic>> getInventory() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String ivUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.getInventory;

    var queryParameters = {
      'token': Storage().token,
    };
    var uri = Uri.parse(ivUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String ivData = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(ivData.toString());

    if (jsonResponse['status'] == false) throw HttpRequestException();

    // final box = Hive.box('inventory');
    // List<InventoryHive> inventoryHIve = [];
    // for (var item in box.toMap().values) {
    //   inventoryHIve.add(InventoryHive.fromJson(item));
    // }

    // (jsonResponse['data'] as Map).cast<String, dynamic>();
    // var invHive = (jsonResponse['data'] as List).cast<Map>();
    // DBMasterInventoryHive().cacheInventory(invHive);

    // return invHive;

    // return jsonResponse['data'].forEach((Map inventoryItem) {
    //   // saveCategories(categories);
    //   DBMasterInventoryHive().getAllInvHive().then((value) {
    //     if (value != null) {
    //       DBMasterInventoryHive().deleteItem().then((value) {
    //         DBMasterInventoryHive().createItem(InventoryHive(
    //           id: inventoryItem['id'],
    //           name: inventoryItem['name'],
    //           type: inventoryItem['type'],
    //           upc: inventoryItem['upc'],
    //           sku: inventoryItem['sku'],
    //         ));
    //       });
    //     } else {
    //       DBMasterInventoryHive().createItem(InventoryHive(
    //         id: inventoryItem['id'],
    //         name: inventoryItem['name'],
    //         type: inventoryItem['type'],
    //         upc: inventoryItem['upc'],
    //         sku: inventoryItem['sku'],
    //       ));
    //     }
    //   });
    // });

    return (jsonResponse['data'] as List).map((inventoryItem) async {
      print("inventoryItem: $inventoryItem");
      DBMasterInventoryHive().createItem(InventoryHive(
        id: inventoryItem['id'],
        name: inventoryItem['name'],
        type: inventoryItem['type'],
        upc: inventoryItem['upc'],
        sku: inventoryItem['sku'],
      ));
      await Future.delayed(const Duration(seconds: 15));
    }).toList();

    // // if (jsonResponse.containsKey('data'))
    // return (jsonResponse['data'] as List).map((inventoryItem) {
    //   // print("inventoryItem: $inventoryItem");

    //   DBMasterInventory().getAllMasterInv().then((value) {
    //     // print('value db inv: $value');
    //     if (value != null) {
    //       DBMasterInventory().deleteAllMasterInv().then((value) {
    //         DBMasterInventory().createMasterInv(Inventory(
    //           id: inventoryItem['id'],
    //           name: inventoryItem['name'],
    //           type: inventoryItem['type'],
    //           upc: inventoryItem['upc'],
    //           sku: inventoryItem['sku'],
    //         ));
    //       });
    //     } else {
    //       DBMasterInventory().createMasterInv(Inventory(
    //         id: inventoryItem['id'],
    //         name: inventoryItem['name'],
    //         type: inventoryItem['type'],
    //         upc: inventoryItem['upc'],
    //         sku: inventoryItem['sku'],
    //       ));
    //     }
    //   });
    // }).toList();
///////////////////////////////////////////////////////////////////////////
    // return jsonResponse['data'];

    // List<dynamic> listIv = [];
    // if (jsonResponse['data'] != null) {
    //   listIv =
    //       jsonResponse['data'].map((item) => Inventory.fromJson(item)).toList();
    //   //   print('value list inv: $listIv');
    //   //   print('value list inv length: ${listIv.length}');

    //   for (int i = 0; i < listIv.length; i++) {
    //     final ivItem = jsonResponse['data'][i];
    //     final id = ivItem['id'];
    //     final name = ivItem['name'];
    //     final type = ivItem['type'];
    //     final upc = ivItem['upc'];
    //     final sku = ivItem['sku'];

    //     DBMasterInventory().getAllMasterInv().then((value) {
    //       print('value db inv: $value');
    //       if (value != null) {
    //         DBMasterInventory().deleteAllMasterInv().then((value) {
    //           DBMasterInventory().createMasterInv(Inventory(
    //             id: id,
    //             name: name,
    //             type: type,
    //             upc: upc,
    //             sku: sku,
    //           ));
    //         });
    //       } else {
    //         DBMasterInventory().createMasterInv(Inventory(
    //           id: id,
    //           name: name,
    //           type: type,
    //           upc: upc,
    //           sku: sku,
    //         ));
    //       }
    //     });
    //   }
    //   // } else {
    //   //   throw HttpRequestException();
    // }
    // return listIv;
  }

  Future<List<dynamic>> getCustomer() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String custUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.getCustomer;

    var queryParameters = {
      'token': Storage().token,
    };
    var uri = Uri.parse(custUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String custData = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(custData.toString());
    print('value db cust: ${jsonResponse['data']}');

    List<dynamic> listCust = [];
    if (jsonResponse['data'] != null) {
      listCust =
          jsonResponse['data'].map((item) => Customer.fromJson(item)).toList();

      for (int i = 0; i < listCust.length; i++) {
        final custItem = jsonResponse['data'][i];
        final id = custItem['id'];
        final name = custItem['name'];
        DBMasterCustomer().getAllMasterCust().then((value) {
          print('value db cust: $value');
          if (value != null) {
            DBMasterCustomer().deleteAllMasterCust().then((value) {
              DBMasterCustomer().createMasterCust(Customer(id: id, name: name));
            });
          } else {
            DBMasterCustomer().createMasterCust(Customer(id: id, name: name));
          }
        });
      }
    }
    return listCust;
  }

  Future<List<dynamic>> getSupplier() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String supUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.getSupplier;

    var queryParameters = {
      'token': Storage().token,
    };
    var uri = Uri.parse(supUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String supData = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(supData.toString());
    print('value db sup: ${jsonResponse['data']}');

    List<dynamic> listSup = [];
    if (jsonResponse['data'] != null) {
      listSup =
          jsonResponse['data'].map((item) => Supplier.fromJson(item)).toList();

      for (int i = 0; i < listSup.length; i++) {
        final supItem = jsonResponse['data'][i];
        final id = supItem['id'];
        final name = supItem['name'];

        DBMasterSupplier().getAllMasterSupplier().then((value) {
          print('value db sup: $value');
          if (value != null) {
            DBMasterSupplier().deleteAllMasterSupplier().then((value) {
              DBMasterSupplier()
                  .createMasterSupplier(Supplier(id: id, name: name));
            });
          } else {
            DBMasterSupplier()
                .createMasterSupplier(Supplier(id: id, name: name));
          }
        });
      }
    }
    return listSup;
  }

  Future<List<dynamic>> getStatus() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String supUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.getStatus;

    var queryParameters = {
      'token': Storage().token,
    };
    var uri = Uri.parse(supUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String supData = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(supData.toString());
    // print('value db sup: ${jsonResponse['data']}');

    return List<dynamic>.from(jsonResponse['data']);
  }

  Future<List<dynamic>> getReason() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String supUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.getReason;

    var queryParameters = {
      'token': Storage().token,
    };
    var uri = Uri.parse(supUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String supData = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(supData.toString());
    // print('value db sup: ${jsonResponse['data']}');

    List<dynamic> listReason = [];
    if (jsonResponse['data'] != null) {
      listReason = jsonResponse['data']
          .map((item) => RejectReason.fromJson(item))
          .toList();

      for (int i = 0; i < listReason.length; i++) {
        final reasonItem = jsonResponse['data'][i];
        final id = reasonItem['id'];
        final code = reasonItem['code'];
        final desc = reasonItem['desc'];

        DBMasterReason().getAllMasterReason().then((value) {
          // print('value db reason: $value');
          if (value != null) {
            DBMasterReason().deleteAllMasterReason().then((value) {
              DBMasterReason().createMasterReason(
                  RejectReason(id: id, code: code, desc: desc));
            });
          } else {
            DBMasterReason().createMasterReason(
                RejectReason(id: id, code: code, desc: desc));
          }
        });
      }
    }
    return listReason;

    // return List<dynamic>.from(jsonResponse['data']);
  }
}
