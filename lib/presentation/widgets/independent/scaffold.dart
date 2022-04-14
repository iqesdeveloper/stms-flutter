import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/presentation/features/authentication/authentication.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class StmsScaffold extends StatelessWidget {
  final Color? background;
  final Widget? leading;
  final double? leadingWidth;
  final String title;
  final Widget body;
  final List<String>? tabBarList;
  final TabController? tabController;
  final Color? appBarColor;

  const StmsScaffold({
    Key? key,
    this.background,
    this.leading,
    this.leadingWidth,
    required this.title,
    required this.body,
    this.tabBarList,
    this.tabController,
    this.appBarColor = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tabBars = <Tab>[];
    var _theme = Theme.of(context);
    if (tabBarList != null) {
      for (var i = 0; i < tabBarList!.length; i++) {
        tabBars.add(Tab(key: UniqueKey(), text: tabBarList![i]));
      }
    }

    var tabWidget;
    if (tabBars.isNotEmpty) {
      tabWidget = TabBar(
          unselectedLabelColor: _theme.primaryColor,
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          labelColor: _theme.primaryColor,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: tabBars,
          controller: tabController,
          indicatorColor: _theme.colorScheme.secondary,
          indicatorSize: TabBarIndicatorSize.tab);
    }
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        leadingWidth: leadingWidth,
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: tabWidget,
        backgroundColor: appBarColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context)
                ..add(AuthenticationLoggedOut());
              showSuccess('Logout Successfully');
              Navigator.of(context).pushNamedAndRemoveUntil(
                  StmsRoutes.login, (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: body,
      // bottomNavigationBar: JomNGoBottomMenu(bottomMenuIndex, isDriver),
      resizeToAvoidBottomInset: false,
    );
  }
}
