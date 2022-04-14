import 'package:stms/data/model/profile/user_profile.dart';
import 'package:stms/domain/entities/user/user_entity.dart';

abstract class UserRepository {
  Future<String> login({
    required UserEntity user,
  });

  // Future<bool> verifyToken({required String token});

  // Future<String> register({
  //   required String surname,
  //   required String forename,
  //   required String name,
  //   required String email,
  //   required String contact,
  //   required String password,
  // });

  // Future<bool> verifyOtp({required String token, required String otpCode});

  Future<UserProfile> getUserProfile({required String token});

  // Future<String> forgotPassword({
  //   required String contact,
  // });

  // Future<bool> verifyPasswordOtp({
  //   required String token,
  //   required String password,
  //   required String otpCode
  // });

  // Future<String> generateOtp({
  //   required String contact,
  //   required String sendVia,
  //   required String purpose,
  // });

  // Future<bool> updateProfile({required String token, required String name, required String surname, required String forename});

  // Future<bool> updateProfilePhoto({required String token, required String image});

  // Future<bool> changePassword({required String token, required String password});

  // Future<bool> changeAddress({
  //   required String token,
  //   required String address1,
  //   required String address2,
  //   required String city,
  //   required String postal,
  //   required String states,
  //   required String country,
  // });

  // Future<String> sendEmailVerify({
  //   required String token,
  //   required String email,
  // });
}
