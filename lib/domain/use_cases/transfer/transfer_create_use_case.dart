// // import 'package:iqe_stms/data/repositories/abstract/transaction_repository.dart';
// import 'package:iqe_stms/data/repositories/abstract/transfer_repository.dart';
// // import 'package:iqe_stms/domain/entities/transaction/transaction_entity.dart';
// import 'package:iqe_stms/domain/use_cases/base_use_case.dart';
// import 'package:iqe_stms/locator.dart';

// abstract class TransferCreateUseCase
//     implements BaseUseCase<TransferCreateResult, TransferCreateParams> {}

// class TransferCreateUseCaseImpl implements TransferCreateUseCase {
//   @override
//   Future<TransferCreateResult> execute(TransferCreateParams params) async {
//     try {
//       TransferRepository transferRepository = sl();
//       var idTransfer = await transferRepository.transfer(
//         transferDocNo: params.transfer.transferDocNo,
//         stiType: params.transfer.stiType,
//         stiBatch: params.transfer.stiBatch,
//         status: params.transfer.status,
//         rejectReason: params.transfer.rejectReason,
//         receiveDate: params.transfer.receiveDate,
//         shipDate: params.transfer.shipDate,
//         custName: params.transfer.custName,
//       );

//       return TransferCreateResult(
//         idTransfer: idTransfer,
//         result: true,
//       );
//     } catch (e) {
//       throw (e);
//     }
//   }
// }

// class TransferCreateResult extends UseCaseResult {
//   String idTransfer;

//   // var serialId;

//   TransferCreateResult(
//       {required this.idTransfer, Exception? exception, bool? result})
//       : super(exception: exception, result: result);

//   // get idTrans => null;
// }

// class TransferCreateParams {
//   TransferEntity transfer;

//   TransferCreateParams({required this.transfer});
// }

// class TransferCreateException implements Exception {
//   String error;

//   TransferCreateException({required this.error});
// }
