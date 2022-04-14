import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/count/view/count_view.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../profile/profile.dart';
import '../wrapper.dart';

class CountScreen extends StatefulWidget {
  CountScreen({Key? key}) : super(key: key);

  @override
  _CountScreenState createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
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
        title: 'Stock Transfer',
        body: CountWrapper(),
      );
    }));
  }
}

class CountWrapper extends StatefulWidget {
  @override
  _CountWrapperState createState() => _CountWrapperState();
}

class _CountWrapperState extends StmsWrapperState<CountWrapper> {
  @override
  Widget build(BuildContext context) {
    return
        // MultiBlocProvider(
        //   providers: [
        //     // BlocProvider<WalletBloc>(
        //     //   create: (context) => WalletBloc(),
        //     // )
        //   ],
        //   child:
        MultiBlocListener(
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
        CountView(changeView: changePage),
        // TransferInView(changeView: changePage),
        // ItemView(changeView: changePage),
      ]),
      // ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:iqe_stms/presentation/widgets/independent/scaffold.dart';

// class TransferScreen extends StatefulWidget {
//   const TransferScreen({Key? key}) : super(key: key);

//   @override
//   _TransferScreenState createState() => _TransferScreenState();
// }

// class _TransferScreenState extends State<TransferScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;

//     return SafeArea(
//       child: StmsScaffold(
//         title: 'Stock Transfer',
//         body: Container(
//           padding: EdgeInsets.all(10),
//           color: Colors.white,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 alignment: Alignment.center,
//                 child: MaterialButton(
//                   onPressed: () {},
//                   child: Container(
//                     height: height * 0.2,
//                     width: width * 0.4,
//                     color: Colors.amber,
//                     alignment: Alignment.center,
//                     child: Text(
//                       'IN',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: height * 0.05),
//               Container(
//                 alignment: Alignment.center,
//                 child: MaterialButton(
//                   onPressed: () {},
//                   child: Container(
//                     height: height * 0.2,
//                     width: width * 0.4,
//                     color: Colors.amber,
//                     alignment: Alignment.center,
//                     child: Text(
//                       'OUT',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
