// import 'package:stms/data/api/repositories/remote_user_repository.dart';
// import 'package:stms/data/model/profile/user_profile.dart';
import 'package:stms/data/api/repositories/remote_transfer_repository.dart';
import 'package:stms/data/repositories/abstract/transfer_repository.dart';
// import 'package:stms/domain/entities/user/user_entity.dart';

// import 'abstract/user_repository.dart';

class TransferRepositoryImpl extends TransferRepository {
  final RemoteTransferRepository remoteTransferRepository;

  TransferRepositoryImpl({required this.remoteTransferRepository});

  @override
  Future<String> transfer({
    required String transferDocNo,
    required String stiType,
    required String stiBatch,
    required String status,
    required String rejectReason,
    required String receiveDate,
    required String shipDate,
    required String custName,
  }) async {
    return remoteTransferRepository.transfer(
      transferDocNo: transferDocNo,
      stiType: stiType,
      stiBatch: stiBatch,
      status: status,
      rejectReason: rejectReason,
      receiveDate: receiveDate,
      shipDate: shipDate,
      custName: custName,
    );
  }
}
