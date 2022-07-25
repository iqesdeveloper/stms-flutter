import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static final Storage _instance = Storage._internal();

  factory Storage() => _instance;

  Storage._internal();

  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String license = '';
  String licenseKey = '';
  String token = '';
  String userProfile = '';
  String transfer = '';
  String vendor = '';
  String typeScan = '';
  String selectedInvId = '';
  String lineSeqNo = '';

  // Write value
  // await secureStorage.write(key: key, value: value);
}
