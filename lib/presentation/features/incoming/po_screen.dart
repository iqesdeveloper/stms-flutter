import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stms/presentation/features/incoming/view/incoming.dart';
import 'package:stms/presentation/features/incoming/view/purchase_order/po_download.dart';
// import 'package:stms/presentation/features/incoming/view/incoming_view.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../profile/profile.dart';
import '../wrapper.dart';
// import 'account.dart';

class PoScreen extends StatefulWidget {
  PoScreen({Key? key}) : super(key: key);

  @override
  _PoScreenState createState() => _PoScreenState();
}

class _PoScreenState extends State<PoScreen> {
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
        title: 'Incoming - PO',
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
        PoDownloadView(changeView: changePage),
      ]),
      // ),
    );
  }
}
