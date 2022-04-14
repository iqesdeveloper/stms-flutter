import 'package:flutter/material.dart';

@immutable
abstract class SplashState {}

@immutable
class SplashInitial extends SplashState {}

@immutable
class SplashLoading extends SplashState {}

@immutable
class SplashLoaded extends SplashState {}
