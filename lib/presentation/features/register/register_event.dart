import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class RegisterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class RegisterPressed extends RegisterEvent {
  final String license;

  RegisterPressed({
    required this.license,
  });

  @override
  List<Object> get props => [license];
}
