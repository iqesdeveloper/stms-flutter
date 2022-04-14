import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/presentation/features/authentication/authentication.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';

enum ViewChangeType { Start, Forward, Backward, Exact }

class StmsWrapperState<T> extends State {
  late PageController _viewController;

  PageView getPageView(List<Widget> widgets) {
    return PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _viewController,
        children: widgets);
  }

  void changePage({required ViewChangeType changeType, int? index}) {
    switch (changeType) {
      case ViewChangeType.Forward:
        _viewController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
        break;
      case ViewChangeType.Backward:
        _viewController.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
        break;
      case ViewChangeType.Start:
        _viewController.jumpToPage(0);
        break;
      case ViewChangeType.Exact:
        _viewController.jumpToPage(index!);
        break;
    }
  }

  void showMessengerInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message'),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void showMessengerError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$error'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    _viewController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    throw Exception('Build method should be implemented in child class');
  }

  void sessionExpiredLogOut(String error) {
    ErrorDialog.showErrorDialog(context, '$error\nYou will be logged out.')
        .then((value) {
      BlocProvider.of<AuthenticationBloc>(context)
        ..add(AuthenticationLoggedOut());
      Navigator.of(context).pushNamedAndRemoveUntil(
          StmsRoutes.login, (Route<dynamic> route) => false);
    });
  }
}
