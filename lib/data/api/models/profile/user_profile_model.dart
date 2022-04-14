import 'package:stms/data/api/models/profile/profile_model.dart';
import 'package:stms/domain/entities/profile/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  UserProfileModel({
    required String id,
    ProfileModel? profile,
  }) : super(
          id: id,
          profile: profile,
        );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    var profile = ProfileModel.fromJson(json['profile']);

    return UserProfileModel(
      id: profile.id,
      profile: profile,
    );
  }
}
