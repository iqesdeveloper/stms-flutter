import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/incoming/view/cust_return/cr_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class CustReturnScreen extends StatefulWidget {
  CustReturnScreen({Key? key}) : super(key: key);

  @override
  _CustReturnScreenState createState() => _CustReturnScreenState();
}

class _CustReturnScreenState extends State<CustReturnScreen> {
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
        title: 'Customer Return',
        body: CustReturnWrapper(),
      );
    }));
  }
}

class CustReturnWrapper extends StatefulWidget {
  @override
  _CustReturnWrapperState createState() => _CustReturnWrapperState();
}

class _CustReturnWrapperState extends StmsWrapperState<CustReturnWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      CrCreateView(changeView: changePage),
    ]);
  }
}
