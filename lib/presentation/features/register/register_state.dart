import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class RegisterState extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class RegisterInitial extends RegisterState {}

@immutable
class RegisterProcessing extends RegisterState {}

@immutable
class RegisterSuccess extends RegisterState {}

@immutable
class RegisterError extends RegisterState {
  final String error;

  RegisterError(this.error);

  @override
  List<Object> get props => [error];
}

@immutable
class RegisterFinished extends RegisterState {}
