// // import 'package:stms_ui/domain/entities/delivery/address_entity.dart';
// import 'package:stms_ui/domain/entities/entity.dart';

// class TransactionEntity extends Entity<String> {
//   final String? token;
//   final String? sender;
//   final String? customer;
//   final String? recipient;
//   final String? recAddress;
//   final String? form;
//   final String? company;
//   final String? quantity;
//   final List<String>? serialno;
//   final String? product;
//   final String? job;
//   // final List<AddressEntity> address;

//   TransactionEntity(
//     String id, {
//     required this.token,
//     required this.sender,
//     required this.customer,
//     required this.recipient,
//     required this.recAddress,
//     required this.form,
//     required this.company,
//     required this.quantity,
//     required this.serialno,
//     required this.product,
//     required this.job,
//   }) : super(id);

//   @override
//   Map<String, dynamic> toMap() {
//     // var addressMap = [];
//     // address.forEach((element) {
//     //   addressMap.add(element.toMap());
//     // });

//     return {
//       'token': token,
//       'sender': sender,
//       'customer': customer,
//       'receipient': recipient,
//       'receipientAddress': recAddress,
//       'custom': form,
//       'company': company,
//       'quantity': quantity,
//       'serialn[]': serialno,
//       'product': product,
//       'job': job,
//     };
//   }

//   @override
//   List<Object?> get props => [
//         id,
//         token,
//         sender,
//         customer,
//         recipient,
//         recAddress,
//         form,
//         company,
//         quantity,
//         serialno,
//         product,
//         job,
//       ];
// }
