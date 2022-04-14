import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/outgoing/view/adjust_out/ao_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class AdjustOutScreen extends StatefulWidget {
  AdjustOutScreen({Key? key}) : super(key: key);

  @override
  _AdjustOutScreenState createState() => _AdjustOutScreenState();
}

class _AdjustOutScreenState extends State<AdjustOutScreen> {
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
        title: 'Inventory Adjustment (OUT)',
        body: AdjustOutWrapper(),
      );
    }));
  }
}

class AdjustOutWrapper extends StatefulWidget {
  @override
  _AdjustOutWrapperState createState() => _AdjustOutWrapperState();
}

class _AdjustOutWrapperState extends StmsWrapperState<AdjustOutWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      AoCreateView(changeView: changePage),
    ]);
  }
}
