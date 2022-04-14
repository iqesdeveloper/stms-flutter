import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class AuthenticationAppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AuthenticationAppStarted';
}

// @immutable
// class AuthenticationRegisterStart extends AuthenticationEvent {
//   @override
//   String toString() => 'AuthenticationRegisterStart';
// }

// @immutable
// class AuthenticationOnBoardingStart extends AuthenticationEvent {
//   @override
//   String toString() => 'AuthenticationOnBoardingStart';
// }

// @immutable
// class AuthenticationOnBoardingComplete extends AuthenticationEvent {
//   @override
//   String toString() => 'AuthenticationOnBoardingComplete';
// }

@immutable
class AuthenticationLoggedIn extends AuthenticationEvent {
  final String token;

  AuthenticationLoggedIn({required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'AuthenticationLoggedIn';
}

@immutable
class AuthenticationLoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'AuthenticationLoggedOut';
}
