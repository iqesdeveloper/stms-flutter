import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class AuthenticationUninitialized extends AuthenticationState {}

@immutable
class AuthenticationAuthenticated extends AuthenticationState {}

@immutable
class AuthenticationUnauthenticated extends AuthenticationState {}

// @immutable
// class AuthenticationRegisterStarted extends AuthenticationState {}
