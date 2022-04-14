import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/outgoing/view/purchase_return/pr_download.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../profile/profile.dart';
import '../wrapper.dart';

class PurchaseReturnScreen extends StatefulWidget {
  PurchaseReturnScreen({Key? key}) : super(key: key);

  @override
  _PurchaseReturnScreenState createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
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
        title: 'Purchase Return',
        body: PurchaseReturnWrapper(),
      );
    }));
  }
}

class PurchaseReturnWrapper extends StatefulWidget {
  @override
  _PurchaseReturnWrapperState createState() => _PurchaseReturnWrapperState();
}

class _PurchaseReturnWrapperState
    extends StmsWrapperState<PurchaseReturnWrapper> {
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
        PrDownloadView(changeView: changePage),
      ]),
      // ),
    );
  }
}
