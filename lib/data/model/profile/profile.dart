import 'package:equatable/equatable.dart';
import 'package:stms/data/error/exceptions.dart';
import 'package:stms/domain/entities/entity.dart';
import 'package:stms/domain/entities/profile/profile_entity.dart';

class Profile extends Equatable {
  final String? id;
  final String? name;
  final String? username;
  final String? status;
  final String? loginLicense;

  Profile({
    this.id,
    this.name,
    this.username,
    this.status,
    this.loginLicense,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        status,
        loginLicense,
      ];

  @override
  factory Profile.fromEntity(Entity entity) {
    if (entity is ProfileEntity) {
      return Profile(
        id: entity.id,
        name: entity.name,
        username: entity.username,
        status: entity.status,
        loginLicense: entity.loginLicense,
      );
    } else {
      throw EntityModelMapperException(
          message: 'Entity should be of type ProfileEntity');
    }
  }
}
