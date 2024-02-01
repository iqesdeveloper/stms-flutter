import 'package:bloc/bloc.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/repositories/abstract/license_repository.dart';
// import 'package:iqe_stms/data/repositories/abstract/user_repository.dart';

import 'register.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final LicenseRepository licenseRepository;

  RegisterBloc({
    required this.licenseRepository,
  }) : super(RegisterInitial()){
    on<RegisterEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  @override
  Future<void> mapEventToState(
    event, Emitter<RegisterState> emit,
  ) async {
    // normal register
    if (event is RegisterPressed) {
      emit (RegisterProcessing());
      try {
        final license = await licenseRepository.register(
          license: event.license,
        );

        // await Storage()
        //     .secureStorage
        //     .write(key: 'license_key', value: event.license);

        Storage().license = license;
        emit (RegisterSuccess());
      } catch (error) {
        if (error is String) {
          emit (RegisterError(error));
        } else {
          emit (RegisterError(error.toString()));
        }
      }
    }
  }
}
