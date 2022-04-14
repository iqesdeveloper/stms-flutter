import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/presentation/features/authentication/authentication.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                StmsRoutes.login, (Route<dynamic> route) => false);
          } else if (state is AuthenticationUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                StmsRoutes.register, (Route<dynamic> route) => false);
          }
          // if (state is AuthenticationUnauthenticated) {
          //   Navigator.of(context).pushNamedAndRemoveUntil(
          //       StmsRoutes.login, (Route<dynamic> route) => false);
          // } else if (state is AuthenticationRegisterStarted) {
          //   Navigator.of(context).pushNamedAndRemoveUntil(
          //       StmsRoutes.register, (Route<dynamic> route) => false);
          // }
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // image: DecorationImage(
                  //   fit: BoxFit.cover,
                  //   image: AssetImage('assets/splash/splash.png'),
                  // ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
