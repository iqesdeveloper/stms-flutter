import 'package:stms/domain/entities/profile/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required String id,
    String? name,
    String? username,
    String? status,
    String? loginLicense,
  }) : super(
          id: id,
          name: name,
          username: username,
          status: status,
          loginLicense: loginLicense,
        );

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      status: json['status'],
      loginLicense: json['login_license'],
    );
  }
}
