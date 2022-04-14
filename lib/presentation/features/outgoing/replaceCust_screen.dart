import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/outgoing/view/replace_cust/rc_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class ReplaceCustScreen extends StatefulWidget {
  ReplaceCustScreen({Key? key}) : super(key: key);

  @override
  _ReplaceCustScreenState createState() => _ReplaceCustScreenState();
}

class _ReplaceCustScreenState extends State<ReplaceCustScreen> {
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
        title: 'Repair/Replacement Item to Customer',
        body: RepalceCustWrapper(),
      );
    }));
  }
}

class RepalceCustWrapper extends StatefulWidget {
  @override
  _RepalceCustWrapperState createState() => _RepalceCustWrapperState();
}

class _RepalceCustWrapperState extends StmsWrapperState<RepalceCustWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      RcCreateView(changeView: changePage),
    ]);
  }
}
