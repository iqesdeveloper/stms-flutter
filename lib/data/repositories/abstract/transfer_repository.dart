// import 'package:iqe_stms/data/model/profile/user_profile.dart';
// import 'package:iqe_stms/domain/entities/user/user_entity.dart';

abstract class TransferRepository {
  // Future<String> login({
  //   required UserEntity user,
  // });

  // Future<bool> verifyToken({required String token});

  Future<String> transfer({
    required String transferDocNo,
    required String stiType,
    required String stiBatch,
    required String status,
    required String rejectReason,
    required String receiveDate,
    required String shipDate,
    required String custName,
    // required String item,
  });

  // Future<bool> verifyOtp({required String token, required String otpCode});

  // Future<UserProfile> getUserProfile({required String token});

}
