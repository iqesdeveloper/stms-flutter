import 'package:bloc/bloc.dart';
import 'package:stms/presentation/features/authentication/authentication.dart';
import 'package:stms/presentation/features/splash/splash.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthenticationBloc authenticationBloc;

  SplashBloc({required this.authenticationBloc}) : super(SplashInitial());

  @override
  Stream<SplashState> mapEventToState(
    SplashEvent event,
  ) async* {
    if (event is SplashStart) {
      yield SplashLoading();

      // During the Loading state we can do additional checks like,
      // if the internet connection is available or not etc..

      await Future.delayed(Duration(
          seconds: 3)); // This is to simulate that above checking process

      yield SplashLoaded(); // In this state we can load the HOME PAGE

      authenticationBloc.add(AuthenticationAppStarted());
    }
  }
}
