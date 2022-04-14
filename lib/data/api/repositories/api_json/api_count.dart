import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
// import 'package:stms/data/api/models/count/count_download_model.dart';
import 'package:stms/data/error/exceptions.dart';
// import 'package:stms/data/local_db/count/count.dart';

class CountService {
  Future<List<dynamic>> getcountList(String token) async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String poUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.countDownload;

    var queryParameters = {
      'token': token,
    };
    var uri = Uri.parse(poUrl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String datasection = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(datasection.toString());

    // if (jsonResponse.containsKey('data'))
    return List<dynamic>.from(jsonResponse['data']['lists']);
  }

  Future<List<dynamic>> getCountItem() async {
    //Future<List<Map<String, dynamic>>>
    // final HiveService hiveService = HiveService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var countId = prefs.getString('countID');

    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String countUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.countItemList;

    var queryParameters = <String, String>{
      'sc_id': '$countId',
      'token': Storage().token,
      'encoded': 'true',
    };
    var uri = Uri.parse(countUrl);
    uri = uri.replace(queryParameters: queryParameters);
    // print(uri);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String datasection = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(datasection.toString());

    // if (response.statusCode == 200) {
    List data = jsonResponse['data']['lists']['items'];

    // for (var rawStock in data) {
    // var stockList = StockCount.fromJson(rawStock);
    // await hiveService.addBoxes(stockList, "StockTable");
    // await AppHiveDb.instance.userBox.put(user.login.uuid, user);
    // }

    // }
    prefs.setString('countId_upload', jsonResponse['data']['lists']['sc_id']);
    prefs.setString('countId_info', json.encode(jsonResponse['data']['lists']));

    return data;
    // JsonDecoder _decoder = new JsonDecoder();
    // return _decoder.convert(jsonResponse['data']['lists']['items']);
    // return _decoder.
    // return List<Map<String, dynamic>>.from(
    //     jsonResponse['data']['lists']['items']);
    // return stockCountFromJson(jsonResponse['data']['lists']['items']);
  }

  Future<dynamic> sendToServer(var uploadData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var countID = prefs.getString('countId_upload');

    HttpClient client = new HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    String url = ServerAddressesProd.serverAddress +
        ServerAddressesProd.countTransaction;

    var queryParameters = {
      'token': Storage().token,
    };

    Map data = {
      "sc_id": countID,
      "item": uploadData,
    };

    // print('map data: $data');

    var uri = Uri.parse(url);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.postUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers
        .set('Content-Length', '${utf8.encode(json.encode(data)).length}');
    request.headers.set('Accept', 'application/json');

    request.add(utf8.encode(json.encode(data)));
    print('debug encoded');
    debugPrint(json.encode(data), wrapWidth: 1024);
    print('data encode: ${json.encode(data)}');

    HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      String data = await response.transform(utf8.decoder).join();

      var jsonResponse = jsonDecode(data.toString());
      // debugPrint("$jsonResponse", wrapWidth: 1024);
      print('response: $jsonResponse');
      return jsonResponse;
    } else {
      throw HttpRequestException();
    }
  }
}
