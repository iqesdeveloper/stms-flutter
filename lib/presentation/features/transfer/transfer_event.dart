import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// import 'package:google_place/google_place.dart';
// import 'package:jomngo/data/model/Transfer/delivery_cost.dart';
// import 'package:jomngo/data/model/location/location.dart' as loc;

@immutable
abstract class TransferEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class TransferLoad extends TransferEvent {}

@immutable
class TransferSave extends TransferEvent {
  final String id;
  final String transferDocNo;
  final String stiType;
  final String stiBatch;
  final String status;
  final String rejectReason;
  final String receiveDate;
  final String shipDate;
  final String custName;

  TransferSave({
    required this.id,
    required this.transferDocNo,
    required this.stiType,
    required this.stiBatch,
    required this.status,
    required this.rejectReason,
    required this.receiveDate,
    required this.shipDate,
    required this.custName,
  });

  @override
  String toString() => 'TransferSave';

  @override
  List<Object> get props => [
        id,
        transferDocNo,
        stiType,
        stiBatch,
        status,
        rejectReason,
        receiveDate,
        shipDate,
        custName
      ];
}

@immutable
class TransferReview extends TransferEvent {
  // final TransferCost deCost;
  final String schedule;
  final String date;
  final String vehicle;
  final String weight;
  final String item;
  final String promo;
  // final List<loc.Location> locations;

  TransferReview({
    // required this.TransferCost,
    required this.schedule,
    required this.date,
    required this.vehicle,
    required this.weight,
    required this.item,
    required this.promo,
    // required this.locations,
  });

  @override
  String toString() => 'TransferReview';

  @override
  List<Object> get props => [schedule, vehicle, weight, item, promo];
}

@immutable
class TransferCreate extends TransferEvent {
  // final TransferCost TransferCost;
  final String schedule;
  final String date;
  final String vehicle;
  final String weight;
  final String item;
  final String promo;
  final String payment;
  // final List<loc.Location> locations;

  TransferCreate({
    // required this.TransferCost,
    required this.schedule,
    required this.date,
    required this.vehicle,
    required this.weight,
    required this.item,
    required this.promo,
    required this.payment,
    // required this.locations,
  });

  @override
  String toString() => 'TransferReview';

  @override
  List<Object> get props => [schedule, vehicle, weight, item, promo];
}
