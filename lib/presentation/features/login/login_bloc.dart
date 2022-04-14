import 'package:bloc/bloc.dart';
// import 'package:stms_ui/config/storage.dart';
import 'package:stms/data/repositories/abstract/user_repository.dart';
import 'package:stms/domain/entities/user/user_entity.dart';
import 'package:stms/presentation/features/authentication/authentication.dart';

import 'login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    required this.userRepository,
    required this.authenticationBloc,
  }) : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // normal log in
    if (event is LoginPressed) {
      yield LoginProcessing();
      try {
        // var pushToken =
        //     await Storage().secureStorage.read(key: 'push_token') ?? '';
        // var phone = '${event.code}-${event.phone}';
        var userEntity = UserEntity(
          id: event.license,
          username: event.username,
          password: event.password,
          license: event.license,
        );

        var token = await userRepository.login(
          user: userEntity,
        );

        // var token = await userRepository.logIn(
        //   phone: '${event.code}-${event.phone}',
        //   password: event.password,
        //   pushToken: pushToken,
        // );
        authenticationBloc.add(AuthenticationLoggedIn(token: token));
        yield LoginFinished();
      } catch (error) {
        if (!(error is String)) {
          yield LoginError(error.toString());
        } else {
          yield LoginError(error);
        }
      }
    }
  }
}
