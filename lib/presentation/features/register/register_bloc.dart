import 'package:bloc/bloc.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/repositories/abstract/license_repository.dart';
// import 'package:iqe_stms/data/repositories/abstract/user_repository.dart';

import 'register.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final LicenseRepository licenseRepository;

  RegisterBloc({
    required this.licenseRepository,
  }) : super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    // normal register
    if (event is RegisterPressed) {
      yield RegisterProcessing();
      try {
        final license = await licenseRepository.register(
          license: event.license,
        );

        // await Storage()
        //     .secureStorage
        //     .write(key: 'license_key', value: event.license);

        Storage().license = license;
        yield RegisterSuccess();
      } catch (error) {
        if (error is String) {
          yield RegisterError(error);
        } else {
          yield RegisterError(error.toString());
        }
      }
    }
  }
}
