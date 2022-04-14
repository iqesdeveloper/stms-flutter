import 'dart:convert';
import 'dart:io';

// import 'package:http/http.dart' as http;
import 'package:stms/config/server_address.dart';
import 'package:stms/config/storage.dart';
// import 'package:stms/config/storage.dart';
import 'package:stms/data/api/models/profile/user_profile_model.dart';
// import 'package:stms/data/api/utils.dart';
import 'package:stms/data/error/exceptions.dart';
import 'package:stms/data/model/profile/user_profile.dart';
import 'package:stms/data/repositories/abstract/user_repository.dart';
import 'package:stms/domain/entities/user/user_entity.dart';

class RemoteUserRepository extends UserRepository {
  @override
  Future<String> login({required UserEntity user}) async {
    HttpClient client = new HttpClient();

    String url = ServerAddressesProd.serverAddress + ServerAddressesProd.login;
    var data = json.encode(user.toMap());

    print("map: $data");
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
    Storage().token = jsonResponse['data']['token'];
    return jsonResponse['data']['token'];
  }

  @override
  Future<UserProfile> getUserProfile({required String token}) async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    String sectionurl =
        ServerAddressesProd.serverAddress + ServerAddressesProd.profile;

    var queryParameters = {
      'token': token,
    };
    var uri = Uri.parse(sectionurl);
    uri = uri.replace(queryParameters: queryParameters);

    HttpClientRequest request = await client.getUrl(uri);

    request.headers.set('authorization', 'Basic YWRtaW46YWRtaW4=');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    HttpClientResponse response = await request.close();
    String datasection = await response.transform(utf8.decoder).join();
    // debugPrint("$datasection", wrapWidth: 1024);
    var jsonResponse = jsonDecode(datasection.toString());

    if (response.statusCode == 200) {
      // Map<String, dynamic> jsonResponse;

      // if (!jsonResponse['session']) {
      //   throw InvalidSessionException(message: jsonResponse['message']);
      // }

      if (!jsonResponse['status']) {
        throw jsonResponse['message'];
      }

      // await Storage()
      //     .secureStorage
      //     .write(key: 'license_key', value: jsonResponse['data']['login_license']);
      // await Storage()
      //     .secureStorage
      //     .write(key: 'scan_method', value: jsonResponse['data']['scanMethod']);
      Storage().userProfile = jsonResponse['data']['username'];

      return UserProfile.fromEntity(
          UserProfileModel.fromJson(jsonResponse['data']));
    } else {
      throw HttpRequestException();
    }
  }
}
