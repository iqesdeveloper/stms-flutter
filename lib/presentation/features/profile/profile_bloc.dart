import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/error/exceptions.dart';
import 'package:stms/data/repositories/abstract/user_repository.dart';

import 'profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  @override
  ProfileBloc({required this.userRepository}) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ProfileStart) {
      yield ProfileInitial();
    }
    if (event is ProfileLoad) {
      yield* _mapProfileLoadEventToState(event);
    }
    // if (event is ProfilePhotoUpdate) {
    //   yield* _mapProfilePhotoUpdateEventToState(event);
    // }
    // if (event is ProfileUpdate) {
    //   yield* _mapProfileUpdateEventToState(event);
    // }
    // if (event is ProfileChangePassword) {
    //   yield* _mapProfileChangePasswordEventToState(event);
    // }
    // if (event is ProfileChangeAddress) {
    //   yield* _mapProfileChangeAddressEventToState(event);
    // }
    // if (event is ProfileWalletLoad) {
    //   yield* _mapProfileWalletLoadEventToState(event);
    // }
  }

  Stream<ProfileState> _mapProfileLoadEventToState(ProfileLoad event) async* {
    try {
      if (!(state is ProfileUpdating)) {
        yield ProfileProcessing();
      }
      var userProfile =
          await userRepository.getUserProfile(token: Storage().token);
      yield ProfileLoaded(userProfile: userProfile);
    } catch (e) {
      if (e is InvalidSessionException) {
        yield ProfileSessionError(error: e.message);
      } else {
        yield ProfileError(error: e.toString());
      }
    }
  }

  // Stream<ProfileState> _mapProfilePhotoUpdateEventToState(
  //     ProfilePhotoUpdate event) async* {
  //   try {
  //     yield ProfilePhotoUpdating();
  //     await userRepository.updateProfilePhoto(
  //         token: Storage().token, image: event.image);
  //     add(ProfileLoad());
  //   } catch (e) {
  //     if (e is InvalidSessionException) {
  //       yield ProfileSessionError(error: e.message);
  //     } else {
  //       yield ProfileError(error: e.toString());
  //     }
  //   }
  // }

  // Stream<ProfileState> _mapProfileUpdateEventToState(
  //     ProfileUpdate event) async* {
  //   try {
  //     yield ProfileUpdating();
  //     await userRepository.updateProfile(
  //         token: Storage().token,
  //         name: event.name,
  //         surname: event.surname,
  //         forename: event.forename);
  //     add(ProfileLoad());
  //   } catch (e) {
  //     if (e is InvalidSessionException) {
  //       yield ProfileSessionError(error: e.message);
  //     } else {
  //       yield ProfileError(error: e.toString());
  //     }
  //   }
  // }

  // Stream<ProfileState> _mapProfileChangePasswordEventToState(
  //     ProfileChangePassword event) async* {
  //   try {
  //     yield ProfilePasswordChanging();
  //     await userRepository.changePassword(
  //         token: Storage().token, password: event.password);
  //     add(ProfileLoad());
  //   } catch (e) {
  //     if (e is InvalidSessionException) {
  //       yield ProfileSessionError(error: e.message);
  //     } else {
  //       yield ProfileError(error: e.toString());
  //     }
  //   }
  // }

  // Stream<ProfileState> _mapProfileChangeAddressEventToState(
  //     ProfileChangeAddress event) async* {
  //   try {
  //     yield ProfileAddressUpdating();

  //     await userRepository.changeAddress(
  //         token: Storage().token,
  //         address1: event.address1,
  //         address2: event.address2,
  //         city: event.city,
  //         postal: event.postal,
  //         states: event.states,
  //         country: event.country);
  //     add(ProfileLoad());
  //   } catch (e) {
  //     if (e is InvalidSessionException) {
  //       yield ProfileSessionError(error: e.message);
  //     } else {
  //       yield ProfileError(error: e.toString());
  //     }
  //   }
  // }

  // Stream<ProfileState> _mapProfileWalletLoadEventToState(
  //     ProfileWalletLoad event) async* {
  //   yield ProfileWalletLoading();

  //   add(ProfileLoad());
  // }
}
