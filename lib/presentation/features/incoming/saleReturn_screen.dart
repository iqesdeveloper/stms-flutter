import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/incoming/view/sale_return/sr_download.dart';
// import 'package:stms/presentation/features/incoming/view/paiv/paiv_download.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../profile/profile.dart';
import '../wrapper.dart';

class SaleReturnScreen extends StatefulWidget {
  SaleReturnScreen({Key? key}) : super(key: key);

  @override
  _SaleReturnScreenState createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
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
        title: 'Sales Return',
        body: SaleReturnWrapper(),
      );
    }));
  }
}

class SaleReturnWrapper extends StatefulWidget {
  @override
  _SaleReturnWrapperState createState() => _SaleReturnWrapperState();
}

class _SaleReturnWrapperState extends StmsWrapperState<SaleReturnWrapper> {
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
        SrDownloadView(changeView: changePage),
      ]),
      // ),
    );
  }
}
