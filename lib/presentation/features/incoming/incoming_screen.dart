import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/incoming/view/incoming.dart';
// import 'package:stms/presentation/features/incoming/view/incoming_view.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../profile/profile.dart';
import '../wrapper.dart';
// import 'account.dart';

class IncomingScreen extends StatefulWidget {
  IncomingScreen({Key? key}) : super(key: key);

  @override
  _IncomingScreenState createState() => _IncomingScreenState();
}

class _IncomingScreenState extends State<IncomingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      if (state is ProfileProcessing) {
        return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      }
      return StmsScaffold(
        title: 'Incoming Page',
        body: IncomingWrapper(),
      );
      // return JomNGoScaffold(
      //     title: 'Incoming',
      //     body: IncomingWrapper(),
      //     bottomMenuIndex: state is ProfileLoaded && state.userProfile.profile!.isDriver == '1' ? 4 : 3,
      //     isDriver: state is ProfileLoaded && state.userProfile.profile!.isDriver == '1'
      // );
    }));
  }
}

class IncomingWrapper extends StatefulWidget {
  @override
  _IncomingWrapperState createState() => _IncomingWrapperState();
}

class _IncomingWrapperState extends StmsWrapperState<IncomingWrapper> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
          if (state is ProfileError) {
            ErrorDialog.showErrorDialog(context, state.error).then((value) {
              BlocProvider.of<ProfileBloc>(context).add(ProfileLoad());
            });
          }
          if (state is ProfileSessionError) {
            sessionExpiredLogOut(state.error);
          }
        }),
        // BlocListener<WalletBloc, WalletState>(listener: (context, state) {
        //   if (state is WalletError) {
        //     ErrorDialog.showErrorDialog(context, state.error).then((value) {
        //       BlocProvider.of<ProfileBloc>(context).add(ProfileLoad());
        //     });
        //   }
        //   if (state is WalletSessionError) {
        //     sessionExpiredLogOut(state.error);
        //   }
        // })
      ],
      child: getPageView(<Widget>[
        IncomingView(changeView: changePage),
      ]),
      // ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:iqe_stms/config/routes.dart';
// import 'package:iqe_stms/presentation/features/incoming/view/purchase_order.dart';
// import 'package:iqe_stms/presentation/widgets/independent/icon_button.dart';
// import 'package:iqe_stms/presentation/widgets/independent/scaffold.dart';

// class IncomingScreen extends StatefulWidget {
//   const IncomingScreen({Key? key}) : super(key: key);

//   @override
//   _IncomingScreenState createState() => _IncomingScreenState();
// }

// class _IncomingScreenState extends State<IncomingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: StmsScaffold(
//         title: 'Incoming',
//         body: Container(
//           color: Colors.white,
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   StmsIconButton(
//                     title: 'Purchase Order',
//                     onPressed: () {
//                       Navigator.of(context).pushNamed(StmsRoutes.purchaseOrder);
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (BuildContext context) =>
//                       //         PurchaseOrderView(),
//                       //   ),
//                       // );
//                     },
//                     icon: FontAwesomeIcons.fileInvoice,
//                   ),
//                   StmsIconButton(
//                     title: 'Project Accounting IV (Transfer Return)',
//                     onPressed: () {},
//                     icon: FontAwesomeIcons.fileAlt,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   StmsIconButton(
//                     title: 'Sales Return / Cancel Order from Customer',
//                     onPressed: () {},
//                     icon: Icons.transform_outlined,
//                   ),
//                   StmsIconButton(
//                     title: 'Inventory Adjustment (IN)',
//                     onPressed: () {},
//                     icon: FontAwesomeIcons.fileImport,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   StmsIconButton(
//                     title: 'Return from Customer',
//                     onPressed: () {},
//                     icon: FontAwesomeIcons.exchangeAlt,
//                   ),
//                   StmsIconButton(
//                     title: 'Replacement from Supplier',
//                     onPressed: () {},
//                     icon: FontAwesomeIcons.retweet,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   StmsIconButton(
//                     title: 'Item Modification',
//                     onPressed: () {},
//                     icon: FontAwesomeIcons.wrench,
//                   ),
//                   // Container(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
