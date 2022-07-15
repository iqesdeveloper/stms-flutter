import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/data/local_db/incoming/po/po_scanItem_db.dart';
import 'package:stms/domain/validator.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/error_dialog.dart';
import 'package:stms/presentation/widgets/independent/input_field.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';
import 'package:stms/presentation/widgets/independent/style_button.dart';


// Manual page for serial number manual scan
class PoManual extends StatefulWidget {

  const PoManual({Key? key}) : super(key: key); //, required this.changeView

  @override
  _PoManualState createState() => _PoManualState();
}

class _PoManualState extends State<PoManual> {
  // Initialize list
  List poItemListing = [];

  // Initialize variable
  var selectedLoc,
      selectedInvtry,
      tracking;

  final TextEditingController itemSNController = TextEditingController();        // variable for Text Editing
  final GlobalKey<StmsInputFieldState> itemSNKey = GlobalKey();                  // key use in Text Editing

  // Initialize function
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileProcessing) {
            // Loading screen
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return StmsScaffold(
            title: '',
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  // Item Serial No Text field
                  Container(
                    decoration: ShapeDecoration(
                      shape: ContinuousRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          style: BorderStyle.solid,
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    // Item Serial No content
                    child: StmsInputField(
                      key: itemSNKey,
                      controller: itemSNController,
                      hint: 'Item Serial No',
                      validator: Validator.valueExists,
                      textline: TextDecoration.none,
                    ),
                  ),
                  // SELECT Button
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: ButtonTheme(
                          minWidth: 200,
                          height: 50,
                          child: StmsStyleButton(
                            title: 'ENTER',
                            backgroundColor: Colors.amber,
                            textColor: Colors.black,
                            onPressed: () {
                              // Call saveData function
                              saveData(itemSNController.text);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to check and store data
  Future<void> saveData(String serial) async {
    // SharedPreferences use to get and save selected data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if form text field got value in or not
    if (itemSNKey.currentState?.validate() != null) {
      // If not value
      ErrorDialog.showErrorDialog(context, 'Serial Number cannot be empty');
    } else {
      // If got value
      // Get data from DB
      DBPoItem().getAllPoItem().then((value) {
        // Check if got data in DB or not
        if (value != null) {
          // If got data
          poItemListing = value;                                                 // Get DB value into poItemListing variable

          // Compare similar item based on item serial number
          var itemPO = poItemListing.firstWhereOrNull(
              (element) => element['item_serial_no'] == serial);

          // Check if compare value present of not
          if (null == itemPO) {
            // If no value
            prefs.setString("itemBarcode", serial);

            // Navigate to poItemDetail page
            Navigator.of(context).pushNamed(StmsRoutes.poItemDetail);
          } else {
            // If got value
            ErrorDialog.showErrorDialog(context, 'Serial No already exists.');
          }
        } else {
          // If no data in DB
          prefs.setString("itemBarcode", serial);

          // Navigate to poItemDetail page
          Navigator.of(context).pushNamed(StmsRoutes.poItemDetail);
        }
      });
    }
  }
}
