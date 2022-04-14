import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/outgoing/view/return_vendor/rv_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class ReturnVendorScreen extends StatefulWidget {
  ReturnVendorScreen({Key? key}) : super(key: key);

  @override
  _ReturnVendorScreenState createState() => _ReturnVendorScreenState();
}

class _ReturnVendorScreenState extends State<ReturnVendorScreen> {
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
        title: 'Return to Vendor',
        body: ReturnVendorWrapper(),
      );
    }));
  }
}

class ReturnVendorWrapper extends StatefulWidget {
  @override
  _ReturnVendorWrapperState createState() => _ReturnVendorWrapperState();
}

class _ReturnVendorWrapperState extends StmsWrapperState<ReturnVendorWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      RvCreateView(changeView: changePage),
    ]);
  }
}
