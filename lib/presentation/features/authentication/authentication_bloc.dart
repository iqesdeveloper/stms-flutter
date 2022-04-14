import 'package:bloc/bloc.dart';
import 'package:stms/data/repositories/abstract/license_repository.dart';
// import 'package:stms/presentation/features/register/register_bloc.dart';
// import 'package:stms/data/repositories/abstract/license_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/repositories/abstract/user_repository.dart';
import 'package:stms/presentation/features/profile/profile.dart';
// import 'package:iqe_stms/presentation/features/profile/profile_event.dart';
// import 'package:iqe_stms/presentation/features/profile/profile_state.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final ProfileBloc profileBloc;
  final UserRepository userRepository;
  final LicenseRepository licenseRepository;

  AuthenticationBloc({
    required this.profileBloc,
    required this.userRepository,
    required this.licenseRepository,
  }) : super(AuthenticationUninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    // app start
    if (event is AuthenticationAppStarted) {
      yield* _mapAuthenticationAppStartedEventToState();
      // var licenseKey = await _getLicenseKey();

      // if (licenseKey != '0') {
      //   yield* _mapAuthenticationAppStartedEventToState();
      // } else {
      //   add(AuthenticationOnBoardingStart());
      // }
    }

    if (event is AuthenticationLoggedIn) {
      yield* _mapAuthenticatedLoggedInEventToState(event.token);
    }

    if (event is AuthenticationLoggedOut) {
      yield* _mapAuthenticatedLoggedOutEventToState();
    }

    // // app start
    // if (event is AuthenticationAppStarted) {
    //   var licenseKey = await _getLicenseKey();

    //   if (licenseKey != '0') {
    //     yield* _mapAuthenticationAppStartedEventToState();
    //   } else {
    //     add(AuthenticationRegisterStart());
    //   }
    // }
    // if (event is AuthenticationLoggedIn) {
    //   yield* _mapAuthenticatedLoggedInEventToState(event.token);
    // }

    // if (event is AuthenticationLoggedOut) {
    //   yield* _mapAuthenticatedLoggedOutEventToState();
    // }
  }

  Stream<AuthenticationState>
      _mapAuthenticationAppStartedEventToState() async* {
    var licenseKey = await _getLicenseKey();
    print('license key: $licenseKey');

    if (licenseKey != '0') {
      yield AuthenticationAuthenticated();
    } else {
      yield AuthenticationUnauthenticated();
    }
  }

  Stream<AuthenticationState> _mapAuthenticatedLoggedInEventToState(
      String token) async* {
    Storage().token = token;
    await _saveToken(token);

    profileBloc.add(ProfileLoad());

    yield AuthenticationAuthenticated();
  }

  Stream<AuthenticationState> _mapAuthenticatedLoggedOutEventToState() async* {
    var profileState = profileBloc.state;
    if (profileState is ProfileLoaded) {
      // var profile = profileState.userProfile.profile;
      // if (profile != null && profile.isDriver == '1' && profile.isWorking == '1') {
      //   var token = Storage().token;
      // workBloc.add(WorkEnd(token: token));
      // }
    }

    Storage().token = '';
    // Storage().job = '';
    await _deleteToken();
    profileBloc.add(ProfileStart());
    yield AuthenticationUnauthenticated();
  }

  /// delete from keystore/keychain
  Future<void> _deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Storage().token = '';
    // Storage().job = '';
    await Storage().secureStorage.delete(key: 'access_token');
    await Storage().secureStorage.delete(key: 'job');
    await Storage().secureStorage.delete(key: 'userProfile');
    await Storage().secureStorage.delete(key: 'transfer');
    await prefs.remove('serial');
    await prefs.remove('countId_info');
    await prefs.remove('paiv_info');
    await prefs.remove('paivLoc');
    await prefs.remove('poReceiptType');
    await prefs.remove('poId_info');
    await prefs.remove('poLocation');
    await prefs.remove('sr_info');
    await prefs.remove('srLoc');
    await prefs.remove('paivt_info');
    await prefs.remove('paivtLoc');
    await prefs.remove('pr_info');
    await prefs.remove('prLoc');
    await prefs.remove('si_info');
    await prefs.remove('siLoc');
  }

  /// write to keystore/keychain
  Future<void> _saveToken(String token) async {
    await Storage().secureStorage.write(key: 'access_token', value: token);
  }

  /// delete from keystore/keychain
  // Future<void> _deleteStorage() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   await Storage().secureStorage.delete(key: 'job');
  //   await ('serial');
  // }

  Future<String> _getLicenseKey() async {
    return await Storage().secureStorage.read(key: 'license_key') ?? '0';
  }

  // /// read to keystore/keychain
  // Future<String> _getToken() async {
  //   return await Storage().secureStorage.read(key: 'access_token') ?? '';
  // }

  // /// write to keystore/keychain
  // Future<void> _saveOnBoarding() async {
  //   await Storage().secureStorage.write(key: 'on_boarding', value: '1');
  // }

  // Future<String> _getOnBoarding() async {
  //   return await Storage().secureStorage.read(key: 'on_boarding') ?? '0';
  // }
}
