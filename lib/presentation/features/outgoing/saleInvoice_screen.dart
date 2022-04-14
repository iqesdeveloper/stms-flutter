import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/outgoing/view/sale_invoice/si_download.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../profile/profile.dart';
import '../wrapper.dart';

class SaleInvoiceScreen extends StatefulWidget {
  SaleInvoiceScreen({Key? key}) : super(key: key);

  @override
  _SaleInvoiceScreenState createState() => _SaleInvoiceScreenState();
}

class _SaleInvoiceScreenState extends State<SaleInvoiceScreen> {
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
        title: 'Sales Invoice',
        body: SaleInvoiceWrapper(),
      );
    }));
  }
}

class SaleInvoiceWrapper extends StatefulWidget {
  @override
  _SaleInvoiceWrapperState createState() => _SaleInvoiceWrapperState();
}

class _SaleInvoiceWrapperState extends StmsWrapperState<SaleInvoiceWrapper> {
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
        SiDownloadView(changeView: changePage),
      ]),
      // ),
    );
  }
}
