import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/error/exceptions.dart';

class PaivtService {
  Future<List<dynamic>> getPaivtList(String token) async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String paivtUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.paivtDownload;

    var queryParameters = {
      'token': token,
    };
    var uri = Uri.parse(paivtUrl);
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

  Future<List<Map<String, dynamic>>> getPaivtItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var paivtId = prefs.getString('paivtID');

    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String paivtUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.paivtItemList;

    var queryParameters = <String, String>{
      'out_paiv_id': '$paivtId',
      'token': Storage().token,
      'encoded': 'true',
    };
    var uri = Uri.parse(paivtUrl);
    uri = uri.replace(queryParameters: queryParameters);
    // print(uri);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String datasection = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(datasection.toString());

    prefs.setString(
        'paivtId_upload', jsonResponse['data']['lists']['out_paiv_id']);
    prefs.setString('paivt_info', json.encode(jsonResponse['data']['lists']));

    return List<Map<String, dynamic>>.from(
        jsonResponse['data']['lists']['items']);
  }

  Future<dynamic> sendToServer(var uploadData, var shipDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var paivtID = prefs.getString('paivtId_upload');
    var paivtLoc = prefs.getString('paivtLoc');

    HttpClient client = new HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    String url = ServerAddressesProd.serverAddress +
        ServerAddressesProd.paivtTransaction;

    var queryParameters = {
      'token': Storage().token,
    };

    Map data = {
      "out_paiv_id": paivtID,
      "ship_date": shipDate,
      "location": paivtLoc,
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
    // print('data encode: ${json.encode(data)}');

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
