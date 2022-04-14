import 'package:flutter/material.dart';
// import 'package:stms_ui/config/theme.dart';
// import 'package:jomngo/data/model/country_code.dart';

class StmsSelectValue<T> extends StatefulWidget {
  final List<T> availableValues;
  final T selectedValue;
  final String? hint;
  final double horizontalPadding;
  final Function(T) onClick;
  final String? error;
  final double width;
  final InputBorder? border;

  const StmsSelectValue({
    Key? key,
    required this.availableValues,
    required this.selectedValue,
    this.hint,
    this.horizontalPadding = 16.0,
    required this.onClick,
    this.error,
    required this.width,
    this.border,
  }) : super(key: key);

  @override
  StmsSelectValueState<T> createState() => StmsSelectValueState<T>();
}

class StmsSelectValueState<T> extends State<StmsSelectValue<T>> {
  late T selectedValue;
  String? error;
  bool isChecked = false;

  @override
  void initState() {
    selectedValue = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    error = widget.error;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: <Widget>[
          Container(
            // color: Colors.blue,
            height: MediaQuery.of(context).size.height / 15,
            width: widget.width,
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: _buildDropDown(context),
              ),
            ),
          ),
          error == null
              ? Container()
              : Text(
                  error!,
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                )
        ],
      ),
    );
  }

  DropdownButtonFormField _buildDropDown(BuildContext context) {
    return DropdownButtonFormField(
      iconSize: 20,
      style: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        border: widget.border,
        labelText: widget.hint,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: Colors.grey[200],
          fontSize: 16,
          // fontWeight: FontWeight.w300,
        ),
        // suffixIcon: error != null
        //     ? Icon(
        //         Icons.close,
        //         color: Colors.blueAccent,
        //       )
        //     : isChecked
        //         ? Icon(Icons.done)
        //         : null,
      ),
      value: selectedValue,
      items: widget.availableValues.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (dynamic newValue) {
        _updateSelectedValue(newValue);
      },
    );
  }

  void _updateSelectedValue(T newValue) {
    selectedValue = newValue;
    setState(() {});
    widget.onClick(selectedValue);
  }
}
