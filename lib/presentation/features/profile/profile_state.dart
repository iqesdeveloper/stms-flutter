import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:stms/data/model/profile/user_profile.dart';

@immutable
class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class ProfileInitial extends ProfileState {}

@immutable
class ProfileProcessing extends ProfileState {}

@immutable
class ProfilePhotoUpdating extends ProfileState {}

@immutable
class ProfileUpdating extends ProfileState {}

@immutable
class ProfileAddressUpdating extends ProfileState {}

@immutable
class ProfilePasswordChanging extends ProfileState {}

@immutable
class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  ProfileLoaded({required this.userProfile});

  @override
  String toString() => 'Profile Loaded';

  @override
  List<Object> get props => [
        userProfile,
      ];
}

@immutable
class ProfileError extends ProfileState {
  final String error;

  ProfileError({required this.error});

  @override
  List<Object> get props => [
        error,
      ];
}

@immutable
class ProfileSessionError extends ProfileState {
  final String error;

  ProfileSessionError({required this.error});

  @override
  List<Object> get props => [
        error,
      ];
}

@immutable
class ProfileException extends ProfileState {
  final String error;

  ProfileException({required this.error});

  @override
  List<Object> get props => [
        error,
      ];
}
