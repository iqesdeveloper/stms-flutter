import 'package:bloc/bloc.dart';
import 'package:stms/data/repositories/abstract/transfer_repository.dart';
// import 'package:stms/locator.dart';
// import 'package:jomngo/config/storage.dart';
// import 'package:jomngo/data/repositories/abstract/user_repository.dart';

// import 'forgot_pass.dart';
import 'transfer.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository transferRepository;
  // final TransactionCreateUseCase _transactionCreateUseCase;

  TransferBloc({
    required this.transferRepository,
  }) : super(TransferInitial());
  // TransferBloc()
  //     : _transactionCreateUseCase = sl(),
  //       super(TransferInitial());

  @override
  Stream<TransferState> mapEventToState(TransferEvent event) async* {
    if (event is TransferSave) {
      yield* _mapTransferSaveEventToState(event);
      // } else if (event is TransferReview) {
      //   yield* _mapTransferReviewEventToState(event);
      // } else if (event is TransferCreate) {
      //   yield* _mapTransferCreateEventToState(event);
    }
  }

  Stream<TransferState> _mapTransferSaveEventToState(
      TransferSave event) async* {
    yield TransferLoading();

    try {
      // var transferId = DateTime.now().millisecondsSinceEpoch;
      // print('datetime: $transferId');

      yield TransferSent();
    } catch (e) {
      yield TransferError(error: e.toString());
    }
  }
}

// class ForgotPassBloc extends Bloc<ForgotPassEvent, ForgotPassState> {

//   final UserRepository userRepository;

//   ForgotPassBloc({
//     required this.userRepository
//   }) : super(ForgotPassInitial());

//   @override
//   Stream<ForgotPassState> mapEventToState(ForgotPassEvent event) async* {
//     if (event is ForgotPassReset) {
//       yield* _mapForgotPassResetToState(event);
//     }

//     if (event is ForgotPassOtpSend) {
//       yield* _mapForgotPassOtpSendToState(event);
//     }

//     if (event is ForgotPassOtpResend) {
//       yield* _mapForgotPassOtpResendToState(event);
//     }
//   }

//   Stream<ForgotPassState> _mapForgotPassResetToState(ForgotPassReset event) async* {
//     yield ForgotPassProcessing();

//     try {
//       String contact = '${event.code}-${event.contact}';

//       var otpToken = await userRepository.forgotPassword(
//           contact: contact
//       );

//       Storage().otpToken = otpToken;
//       Storage().contact = contact;

//       yield ForgotPassSent();
//     }
//     catch (e) {
//       yield ForgotPassError(e.toString());
//     }
//   }

//   Stream<ForgotPassState> _mapForgotPassOtpSendToState(ForgotPassOtpSend event) async* {
//     yield ForgotPassProcessing();
//     try {
//       var isReset = await userRepository.verifyPasswordOtp(
//         token: Storage().otpToken,
//         password: event.password,
//         otpCode: event.otpCode,
//       );

//       if (isReset) {
//         Storage().contact = '';
//         Storage().otpToken = '';
//         yield ForgotPassOtpVerified();
//       }
//     }
//     catch (e) {
//       yield ForgotPassError(e.toString());
//     }
//   }

//   Stream<ForgotPassState> _mapForgotPassOtpResendToState(ForgotPassOtpResend event) async* {
//     yield ForgotPassProcessing();
//     try {
//       var otpToken = await userRepository.generateOtp(
//         contact: Storage().contact,
//         sendVia: 'contact',
//         purpose: event.purpose,
//       );

//       Storage().otpToken = otpToken;

//       yield ForgotPassSent();
//     }
//     catch (e) {
//       yield ForgotPassError(e.toString());
//     }
//   }
// }
