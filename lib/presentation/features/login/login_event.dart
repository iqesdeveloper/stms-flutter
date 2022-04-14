import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class LoginPressed extends LoginEvent {
  final String username;
  final String password;
  final String license;

  LoginPressed(
      {required this.username, required this.password, required this.license});

  @override
  List<Object> get props => [username, password, license];
}
