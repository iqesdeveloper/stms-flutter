import 'package:stms/domain/entities/entity.dart';

class UserEntity extends Entity<String> {
  final String? username;
  final String? password;
  final String? license;

  UserEntity({
    required String id,
    this.username,
    this.password,
    this.license,
  }) : super(id);

  @override
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'license': license,
    };
  }

  @override
  List<Object?> get props => [id, username, password];
}
