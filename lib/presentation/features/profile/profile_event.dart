import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class ProfileStart extends ProfileEvent {}

@immutable
class ProfileLoad extends ProfileEvent {}
