import 'dart:convert';
import 'dart:io';

// import 'package:http/http.dart' as http;
import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
// import 'package:stms/data/api/models/profile/user_profile_model.dart';
// import 'package:stms/data/api/utils.dart';
// import 'package:stms/data/error/exceptions.dart';
import 'package:stms/data/repositories/abstract/license_repository.dart';
// import 'package:stms/data/model/profile/user_profile.dart';
// import 'package:stms/data/repositories/abstract/user_repository.dart';
// import 'package:stms/domain/entities/user/user_entity.dart';

class RemoteLicenseRepository extends LicenseRepository {
  @override
  Future<String> register({required String license}) async {
    HttpClient client = new HttpClient();

    String url =
        ServerAddressesProd.serverAddress + ServerAddressesProd.register;
    var data = json.encode(<String, String?>{
      'license': license,
    });

    // print("map: $map");
    // debugPrint("${json.encode(map)}", wrapWidth: 1024);

    HttpClientRequest request = await client.postUrl(
      Uri.parse(url),
    );

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Content-Length', '${utf8.encode(data).length}');
    request.headers.set('Accept', 'application/json');

    request.add(utf8.encode(data));

    HttpClientResponse response = await request.close();
    // print(response.statusCode);
    // if (response.statusCode == 200) {
    String dataRes = await response.transform(utf8.decoder).join();
    var jsonResponse = jsonDecode(dataRes.toString());
    //   // print(jsonResponse);

    //   if (jsonResponse['status'] == true) {
    //     throw jsonResponse['message'];
    //   }
    //   return jsonResponse['data']['token'];
    // }

    if (response.statusCode != 200 || !jsonResponse['status']) {
      throw jsonResponse['message'];
      // throw response.statusCode; // + jsonResponse['message'];
    }
    await Storage()
        .secureStorage
        .write(key: 'license_key', value: jsonResponse['data']);

    return jsonResponse['data'];
  }
}
