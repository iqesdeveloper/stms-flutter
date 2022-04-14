import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/error/exceptions.dart';

class PaivService {
  Future<List<dynamic>> getPaivList(String token) async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String paivUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.paivDownload;

    var queryParameters = {
      'token': token,
    };
    var uri = Uri.parse(paivUrl);
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

  Future<List<Map<String, dynamic>>> getPaivItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var paivId = prefs.getString('paivID');

    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String paivUrl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.paivItemList;

    var queryParameters = <String, String>{
      'paiv_id': '$paivId',
      'token': Storage().token,
      'encoded': 'true',
    };
    var uri = Uri.parse(paivUrl);
    uri = uri.replace(queryParameters: queryParameters);
    // print(uri);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String datasection = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(datasection.toString());

    prefs.setString('poivId_upload', jsonResponse['data']['lists']['paiv_id']);
    prefs.setString('paiv_info', json.encode(jsonResponse['data']['lists']));
    return List<Map<String, dynamic>>.from(
        jsonResponse['data']['lists']['items']);
  }

  Future<dynamic> sendToServer(var uploadData, var shipDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var paivID = prefs.getString('poivId_upload');
    var paivLoc = prefs.getString('paivLoc');

    HttpClient client = new HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    String url =
        ServerAddressesProd.serverAddress + ServerAddressesProd.paivTransaction;

    var queryParameters = {
      'token': Storage().token,
    };

    Map data = {
      "paiv_id": paivID,
      "ship_date": shipDate,
      "location": paivLoc,
      "item": uploadData,
    };

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
