import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/domain/validator.dart';
// import 'package:stms/presentation/features/home/home_screen.dart';
import 'package:stms/presentation/features/login/login.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class LoginScreen extends StatefulWidget {
  // const LoginScreen({Key? key}) : super(key: key);

  @override
  // _LoginScreenState createState() => _LoginScreenState();
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final GlobalKey<StmsInputFieldState> usernameKey = GlobalKey();
  final GlobalKey<StmsInputFieldState> passwordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          // on success delete navigator stack and push to home
          if (state is LoginFinished) {
            showSuccess('Login Successful');
            Navigator.of(context).pushNamedAndRemoveUntil(
              StmsRoutes.home,
              (Route<dynamic> route) => false,
            );
          }
          // on failure show a snackbar
          if (state is LoginError) {
            ErrorDialog.showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          // show loading screen while processing
          if (state is LoginProcessing) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SizedBox(
                      height: 130.0,
                      child: new Image.asset(
                        "assets/stms_logo.jpg",
                      ),
                    ),
                  ),
                  // Container(
                  //   alignment: Alignment.center,
                  //   // padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  //   child: Text('Belhon'),
                  // ),
                  SizedBox(height: MediaQuery.of(context).size.height / 15),
                  StmsInputField(
                    key: usernameKey,
                    controller: usernameController,
                    hint: 'Username',
                    validator: Validator.valueExists,
                    keyboard: TextInputType.emailAddress,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  StmsInputField(
                    key: passwordKey,
                    controller: passwordController,
                    hint: 'Password',
                    validator: Validator.valueExists,
                    keyboard: TextInputType.visiblePassword,
                    isPassword: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  StmsStyleButton(
                    title: 'LOGIN',
                    titleWeight: FontWeight.bold,
                    textColor: Colors.black54,
                    backgroundColor: Colors.amber,
                    onPressed: _validateAndSend,
                    // () {
                    //   Navigator.of(context).pushAndRemoveUntil(
                    //     MaterialPageRoute(
                    //       builder: (BuildContext context) => HomeScreen(),
                    //     ),
                    //     (Route route) => false,
                    //   );
                    // },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _validateAndSend() async {
    if (usernameKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Username cannot be empty');
    } else if (passwordKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'Password cannot be empty');
    } else {
      var licenseKey =
          await Storage().secureStorage.read(key: 'license_key') ?? '';
      BlocProvider.of<LoginBloc>(context).add(
        LoginPressed(
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
          license: licenseKey.trim(),
        ),
      );
    }
  }
}
