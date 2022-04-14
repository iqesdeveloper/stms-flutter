import 'package:equatable/equatable.dart';
import 'package:stms/data/error/exceptions.dart';
import 'package:stms/data/model/profile/profile.dart';
import 'package:stms/domain/entities/entity.dart';
import 'package:stms/domain/entities/profile/user_profile_entity.dart';

class UserProfile extends Equatable {
  final Profile? profile;

  UserProfile({
    this.profile,
  });

  @override
  List<Object?> get props => [
        profile,
      ];

  @override
  factory UserProfile.fromEntity(Entity entity) {
    if (entity is UserProfileEntity) {
      return UserProfile(
        profile: Profile.fromEntity(entity.profile!),
      );
    } else {
      throw EntityModelMapperException(
          message: 'Entity should be of type UserProfileEntity');
    }
  }
}
