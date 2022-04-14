import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/domain/validator.dart';
// import 'package:stms/presentation/features/login/login_screen.dart';
import 'package:stms/presentation/features/register/register.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';
import 'package:stms/presentation/widgets/independent/toast_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  // _RegisterScreenState createState() => _RegisterScreenState();
  State<StatefulWidget> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController licenseController = new TextEditingController();
  // final TextEditingController passwordController = new TextEditingController();
  final GlobalKey<StmsInputFieldState> licenseKey = GlobalKey();
  // final GlobalKey<StmsInputFieldState> passwordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            showSuccess('License Key Registered Successfully.');
            Navigator.of(context).pushNamedAndRemoveUntil(
              StmsRoutes.login,
              (Route<dynamic> route) => false,
            );
          }
          // on failure show a snackbar
          if (state is RegisterError) {
            ErrorDialog.showErrorDialog(context, state.error);
          }
        },
        builder: (context, state) {
          // show loading screen while processing
          if (state is RegisterProcessing) {
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
                    key: licenseKey,
                    controller: licenseController,
                    hint: 'Enter Your License Key',
                    validator: Validator.valueExists,
                    keyboard: TextInputType.text,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  StmsStyleButton(
                    title: 'SEND',
                    titleWeight: FontWeight.bold,
                    textColor: Colors.black54,
                    backgroundColor: Colors.amber,
                    onPressed: _validateAndSend,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _validateAndSend() {
    if (licenseKey.currentState?.validate() != null) {
      ErrorDialog.showErrorDialog(context, 'License cannot be empty');
    } else {
      BlocProvider.of<RegisterBloc>(context).add(
        RegisterPressed(
          license: licenseController.text.trim(),
        ),
      );
    }
  }
}
