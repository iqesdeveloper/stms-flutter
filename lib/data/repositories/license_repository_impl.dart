import 'package:stms/data/api/repositories/remote_license_repository.dart';
// import 'package:iqe_stms/data/model/profile/user_profile.dart';
// import 'package:iqe_stms/domain/entities/user/user_entity.dart';

import 'abstract/license_repository.dart';

class LicenseRepositoryImpl extends LicenseRepository {
  final RemoteLicenseRepository remoteLicenseRepository;

  LicenseRepositoryImpl({required this.remoteLicenseRepository});

  // @override
  // Future<String> logIn({
  //   required String phone,
  //   required String password,
  //   required String pushToken
  // }) async {
  //   return remoteUserRepository.logIn(phone: phone, password: password, pushToken: pushToken);
  // }

  // @override
  // Future<String> logIn({
  //   required UserEntity user
  // }) async {
  //   return remoteUserRepository.logIn(user: user);
  // }

  // @override
  // Future<UserProfile> getUserProfile({required String token}) async {
  //   try {
  //     return remoteUserRepository.getUserProfile(token: token);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  @override
  Future<String> register({
    required String license,
  }) async {
    return remoteLicenseRepository.register(
      license: license,
    );
  }

  // @override
  // Future<bool> verifyToken({
  //   required String token,
  // }) async {
  //   return remoteUserRepository.verifyToken(token: token);
  // }

  // @override
  // Future<bool> verifyOtp(
  //     {required String token, required String otpCode}) async {
  //   return remoteUserRepository.verifyOtp(token: token, otpCode: otpCode);
  // }

  // @override
  // Future<String> forgotPassword({
  //   required String contact,
  // }) async {
  //   return remoteUserRepository.forgotPassword(contact: contact);
  // }

  // @override
  // Future<bool> verifyPasswordOtp(
  //     {required String token,
  //     required String password,
  //     required String otpCode}) async {
  //   return remoteUserRepository.verifyPasswordOtp(
  //       token: token, password: password, otpCode: otpCode);
  // }

  // @override
  // Future<String> generateOtp(
  //     {required String contact,
  //     required String sendVia,
  //     required String purpose}) async {
  //   return remoteUserRepository.generateOtp(
  //       contact: contact, sendVia: sendVia, purpose: purpose);
  // }

  // @override
  // Future<bool> updateProfile(
  //     {required String token,
  //     required String name,
  //     required String surname,
  //     required String forename}) async {
  //   return remoteUserRepository.updateProfile(
  //       token: token, name: name, surname: surname, forename: forename);
  // }

  // @override
  // Future<bool> updateProfilePhoto(
  //     {required String token, required String image}) async {
  //   return remoteUserRepository.updateProfilePhoto(token: token, image: image);
  // }

  // @override
  // Future<bool> changePassword(
  //     {required String token, required String password}) async {
  //   return remoteUserRepository.changePassword(
  //       token: token, password: password);
  // }

  // @override
  // Future<bool> changeAddress(
  //     {required String token,
  //     required String address1,
  //     required String address2,
  //     required String city,
  //     required String postal,
  //     required String states,
  //     required String country}) async {
  //   return remoteUserRepository.changeAddress(
  //       token: token,
  //       address1: address1,
  //       address2: address2,
  //       city: city,
  //       postal: postal,
  //       states: states,
  //       country: country);
  // }

  // @override
  // Future<String> sendEmailVerify({required String token, required String email}) async {
  //   return remoteUserRepository.sendEmailVerify(token: token, email: email);
  // }
}
