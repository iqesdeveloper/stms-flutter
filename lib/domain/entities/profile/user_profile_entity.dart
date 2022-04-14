import 'package:stms/domain/entities/entity.dart';
import 'package:stms/domain/entities/profile/profile_entity.dart';

class UserProfileEntity extends Entity<String> {
  final ProfileEntity? profile;

  UserProfileEntity({
    required String id,
    this.profile,
  }) : super(id);

  @override
  List<Object?> get props => [
        id,
        profile,
      ];
}
