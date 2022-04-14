import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/presentation/features/incoming/view/vendor_replace/vsr_create.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

import '../wrapper.dart';

class VendorReplaceScreen extends StatefulWidget {
  VendorReplaceScreen({Key? key}) : super(key: key);

  @override
  _VendorReplaceScreenState createState() => _VendorReplaceScreenState();
}

class _VendorReplaceScreenState extends State<VendorReplaceScreen> {
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
        title: 'Vendor Stock Replacement',
        body: VendorReplaceWrapper(),
      );
    }));
  }
}

class VendorReplaceWrapper extends StatefulWidget {
  @override
  _VendorReplaceWrapperState createState() => _VendorReplaceWrapperState();
}

class _VendorReplaceWrapperState
    extends StmsWrapperState<VendorReplaceWrapper> {
  @override
  Widget build(BuildContext context) {
    return getPageView(<Widget>[
      VsrCreateView(changeView: changePage),
    ]);
  }
}
