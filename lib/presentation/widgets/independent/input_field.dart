import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:jomngo/config/theme.dart';

class StmsInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator? validator;
  final TextInputType keyboard;
  final int? maxLines;
  final FocusNode? focusNode;
  final VoidCallback? onFinished;
  final bool isPassword;
  final double horizontalPadding;
  final Function? onValueChanged;
  final String? error;
  final TextCapitalization capitalization;
  final Function? onTap;
  final InputBorder? border;
  final bool readOnly;
  final Function? onSaved;
  final TextDecoration? textline;

  const StmsInputField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
    this.focusNode,
    this.onFinished,
    this.isPassword = false,
    this.horizontalPadding = 16.0,
    this.onValueChanged,
    this.error,
    this.capitalization = TextCapitalization.none,
    this.onTap,
    this.border,
    this.readOnly = false,
    this.onSaved,
    this.textline,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StmsInputFieldState();
  }
}

class StmsInputFieldState extends State<StmsInputField> {
  String? error;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: <Widget>[
          Container(
            // color: Colors.blue,
            height: widget.maxLines == 1
                ? MediaQuery.of(context).size.height / 15
                : MediaQuery.of(context).size.height / 10,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: TextFormField(
                onChanged: (value) {
                  if (widget.onValueChanged != null) {
                    widget.onValueChanged!(value);
                  }
                },
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                onSaved: (val) {
                  if (widget.onSaved != null) {
                    widget.onSaved!(val);
                  }
                },
                style: TextStyle(
                  // height: 1.6,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  decoration: widget.textline,
                ),
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboard,
                obscureText: widget.isPassword,
                maxLines: widget.maxLines,
                readOnly: widget.readOnly,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  border: widget.border,
                  labelText: widget.hint,
                  hintText: widget.hint,
                  suffixIcon: error != null
                      ? Icon(
                          Icons.close,
                          color: Colors.redAccent,
                        )
                      : isChecked
                          ? Icon(Icons.done)
                          : null,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                textCapitalization: widget.capitalization,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? validate() {
    if (widget.validator == null) {
      return null;
    }

    setState(() {
      error = widget.validator!(widget.controller.text);
    });
    return error;
  }
}
