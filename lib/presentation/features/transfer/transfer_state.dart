import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// import 'package:jomngo/data/model/delivery/delivery_cost.dart';
// import 'package:jomngo/data/model/location/location.dart';

@immutable
abstract class TransferState extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class TransferInitial extends TransferState {}

@immutable
class TransferError extends TransferState {
  final String error;

  TransferError({required this.error});

  @override
  List<Object> get props => [error];
}

@immutable
class TransferLoading extends TransferState {}

@immutable
class TransferSent extends TransferState {}

@immutable
class TransferLoaded extends TransferState {}

@immutable
class TransferSaveLoading extends TransferState {}

@immutable
class TransferSaveLoaded extends TransferState {
  // final DeliveryCost deliveryCost;
  final String schedule;
  final String date;

  TransferSaveLoaded({required this.schedule, required this.date});

  @override
  String toString() => 'DeliveryNowSaveLoaded';

  @override
  List<Object> get props => [date];
}

@immutable
class TransferReviewLoaded extends TransferState {
  // final DeliveryCost deliveryCost;
  final String schedule;
  final String date;
  final String vehicle;
  final String weight;
  final String item;
  final String promo;
  // final List<Location> locations;

  TransferReviewLoaded({
    // required this.deliveryCost,
    required this.schedule,
    required this.date,
    required this.vehicle,
    required this.weight,
    required this.item,
    required this.promo,
    // required this.locations,
  });

  @override
  String toString() => 'DeliveryReviewLoaded';

  @override
  List<Object> get props => [schedule, vehicle, weight, item, promo];
}

@immutable
class TransferCreated extends TransferState {
  final String orderNo;
  final String schedule;

  TransferCreated({required this.orderNo, required this.schedule});

  @override
  String toString() => 'DeliveryCreated';

  @override
  List<Object> get props => [
        orderNo,
        schedule,
      ];
}

@immutable
class TransferCreateError extends TransferState {
  final String error;

  TransferCreateError({required this.error});

  @override
  List<Object> get props => [error];
}
