import 'package:stms/domain/entities/entity.dart';

class ProfileEntity extends Entity<String> {
  final String? name;
  final String? username;
  final String? status;
  final String? loginLicense;

  ProfileEntity({
    required String id,
    this.name,
    this.username,
    this.status,
    this.loginLicense,
  }) : super(id);

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        status,
        loginLicense,
      ];
}
