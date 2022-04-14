import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/incoming/view/adjust_in/ai_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class AdjustInScreen extends StatefulWidget {
  AdjustInScreen({Key? key}) : super(key: key);

  @override
  _AdjustInScreenState createState() => _AdjustInScreenState();
}

class _AdjustInScreenState extends State<AdjustInScreen> {
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
        title: 'Inventory Adjustment (IN)',
        body: AdjustInWrapper(),
      );
    }));
  }
}

class AdjustInWrapper extends StatefulWidget {
  @override
  _AdjustInWrapperState createState() => _AdjustInWrapperState();
}

class _AdjustInWrapperState extends StmsWrapperState<AdjustInWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      AiCreateView(changeView: changePage),
    ]);
  }
}
