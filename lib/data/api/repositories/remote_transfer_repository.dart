import 'dart:convert';
import 'dart:io';

import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
// import 'package:stms/data/api/models/master/transfer_model.dart';
import 'package:stms/data/repositories/abstract/transfer_repository.dart';
// import 'package:stms/data/repositories/abstract/license_repository.dart';

class RemoteTransferRepository extends TransferRepository {
  @override
  Future<String> transfer({
    required String transferDocNo,
    required String stiType,
    required String stiBatch,
    required String status,
    required String rejectReason,
    required String receiveDate,
    required String shipDate,
    required String custName,
  }) async {
    HttpClient client = new HttpClient();

    String url =
        ServerAddressesProd.serverAddress + ServerAddressesProd.transfer;
    var data = json.encode(<String, String?>{
      'transferDocNo': transferDocNo,
      'stiType': stiType,
      'stiBatch': stiBatch,
      'status': status,
      'rejectReason': rejectReason,
      'receiveDate': receiveDate,
      'shipDate': shipDate,
      'custName': custName,
    });

    HttpClientRequest request = await client.postUrl(
      Uri.parse(url),
    );

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Content-Length', '${utf8.encode(data).length}');
    request.headers.set('Accept', 'application/json');

    request.add(utf8.encode(data));

    HttpClientResponse response = await request.close();
    String dataRes = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(dataRes.toString());

    if (response.statusCode != 200 || !jsonResponse['status']) {
      throw jsonResponse['message'];
    }
    await Storage()
        .secureStorage
        .write(key: 'license_key', value: jsonResponse['data']);

    return jsonResponse['data'];
  }

  // Future<String> logIn({
  //   required String phone,
  //   required String password,
  //   required pushToken}) async {
  //   var header = HttpClient().createHeader(type: RequestType.post);
  //   var route = HttpClient().createUri(ServerAddresses.login);
  //   var data = json.encode(<String, String?>{
  //     'username': phone,
  //     'password': password,
  //     'access': 'mobile',
  //     'pushToken': pushToken,
  //     'isRemember': 'true'
  //   });
  //
  //   try {
  //     var response = await http.post(
  //       route,
  //       headers: header,
  //       body: data,
  //     );
  //     Map jsonResponse = json.decode(response.body);
  //     if (response.statusCode != 200 || !jsonResponse['status']) {
  //       throw jsonResponse['message'];
  //     }
  //     return jsonResponse['data']['token'];
  //   }
  //   catch (e) {
  //     print(e);
  //     throw(e);
  //   }
  // }

  // @override
  // Future<Transfer> transfer(
  //     {required String stiType,
  //     required String stiBatch,
  //     required String status,
  //     required String rejectReason,
  //     required String receiveDate,
  //     required String shipDate,
  //     required String custName,
  //     required String item}) async {
  //   HttpClient client = new HttpClient();

  //   String url = ServerAddresses.serverAddress + ServerAddresses.register;
  //   var data = json.encode(<String, String?>{
  //     'sti_type': license,
  //   });

  //   HttpClientRequest request = await client.postUrl(
  //     Uri.parse(url),
  //   );

  //   request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
  //   request.headers.set('Content-Type', 'application/json');
  //   request.headers.set('Content-Length', '${utf8.encode(data).length}');
  //   request.headers.set('Accept', 'application/json');

  //   request.add(utf8.encode(data));

  //   HttpClientResponse response = await request.close();
  //   String dataRes = await response.transform(utf8.decoder).join();
  //   var jsonResponse = jsonDecode(dataRes.toString());

  //   if (response.statusCode != 200 || !jsonResponse['status']) {
  //     throw jsonResponse['message'];
  //   }
  //   await Storage()
  //       .secureStorage
  //       .write(key: 'license_key', value: jsonResponse['data']);

  //   return jsonResponse['data'];
  // }
}
