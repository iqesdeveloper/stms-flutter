import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/data/repositories/abstract/transfer_repository.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/features/transfer/transfer.dart';
import 'package:stms/presentation/features/transfer/transfer_bloc.dart';
import 'package:stms/presentation/features/transfer/view/transferIn.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class TransferInScreen extends StatefulWidget {
  TransferInScreen({Key? key}) : super(key: key);

  @override
  _TransferInScreenState createState() => _TransferInScreenState();
}

class _TransferInScreenState extends State<TransferInScreen> {
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
        title: Storage().transfer == '1' ? 'Transfer In' : 'Transfer Out',
        body: TransferInWrapper(),
      );
    }));
  }
}

class TransferInWrapper extends StatefulWidget {
  @override
  _TransferInWrapperState createState() => _TransferInWrapperState();
}

class _TransferInWrapperState extends StmsWrapperState<TransferInWrapper> {
  @override
  Widget build(BuildContext context) {
    // return getPageView(<Widget>[
    //   TransferInView(changeView: changePage),
    //   ItemView(changeView: changePage),
    // ]);

    return BlocProvider<TransferBloc>(
      create: (context) => TransferBloc(
        transferRepository: RepositoryProvider.of<TransferRepository>(context),
        // authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      ),
      child: getPageView(<Widget>[
        TransferInView(changeView: changePage),
      ]),
    );
    // return MultiBlocListener(
    //   listeners: [
    //     BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
    //       if (state is ProfileError) {
    //         ErrorDialog.showErrorDialog(context, state.error).then((value) {
    //           BlocProvider.of<ProfileBloc>(context).add(ProfileLoad());
    //         });
    //       }
    //     }),
    //   ],
    //   child: getPageView(<Widget>[
    //     TransferInView(changeView: changePage),
    //     ItemView(changeView: changePage),
    //   ]),
    // );
  }
}
