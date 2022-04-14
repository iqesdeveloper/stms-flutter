import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/incoming/view/im/im_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class ItemModifyScreen extends StatefulWidget {
  ItemModifyScreen({Key? key}) : super(key: key);

  @override
  _ItemModifyScreenState createState() => _ItemModifyScreenState();
}

class _ItemModifyScreenState extends State<ItemModifyScreen> {
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
        title: 'Item Modification',
        body: ItemModifyWrapper(),
      );
    }));
  }
}

class ItemModifyWrapper extends StatefulWidget {
  @override
  _ItemModifyWrapperState createState() => _ItemModifyWrapperState();
}

class _ItemModifyWrapperState extends StmsWrapperState<ItemModifyWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      ImCreateView(changeView: changePage),
    ]);
  }
}
