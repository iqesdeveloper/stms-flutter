import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/config/storage.dart';
import 'package:stms/presentation/features/profile/profile.dart';
import 'package:stms/presentation/widgets/independent/image_button.dart';
import 'package:stms/presentation/widgets/independent/scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var masterCustomer, masterVendor, masterLoc, masterInventory, masterReason;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
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
            leadingWidth: width * 0.55,
            leading: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Container(
                alignment: Alignment.centerLeft,
                // color: Colors.blue,
                height: height * 0.02,
                child: Text(
                  ' ${Storage().userProfile}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            title: '',
            body: Container(
              height: height,
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // color: Colors.amber,
                    height: height * 0.13,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/stms_logo.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StmsImageButton(
                        title: 'Master File',
                        assetImage: "assets/master.png",
                        onPressed: () {
                          Navigator.of(context).pushNamed(StmsRoutes.master);
                        },
                      ),
                      StmsImageButton(
                        title: 'Incoming',
                        assetImage: "assets/incoming.png",
                        onPressed: () {
                          Navigator.of(context).pushNamed(StmsRoutes.incoming);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StmsImageButton(
                        title: 'Outgoing',
                        onPressed: () {
                          Navigator.of(context).pushNamed(StmsRoutes.outgoing);
                        },
                        assetImage: "assets/outgoing.png",
                      ),
                      StmsImageButton(
                        title: 'Transfer',
                        assetImage: "assets/transfer.png",
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(StmsRoutes.transferItem);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StmsImageButton(
                        title: 'Stock Count',
                        onPressed: () {
                          // Navigator.of(context)
                          //     .pushNamed(StmsRoutes.stockCount);
                        },
                        assetImage: "assets/calculator.png",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // checkMasterDownload() {
  //   DBMasterCustomer().getAllMasterCust().then((value) {
  //     masterCustomer = value;
  //   });
  //   DBMasterSupplier().getAllMasterSupplier().then((value) {
  //     masterVendor = value;
  //   });
  //   DBMasterLocation().getAllMasterLoc().then((value) {
  //     masterLoc = value;
  //   });
  //   DBMasterInventory().getAllMasterInv().then((value) {
  //     masterInventory = value;
  //   });
  //   DBMasterReason().getAllMasterReason().then((value) {
  //     masterReason = value;
  //   });

  //   if (masterCustomer == null &&
  //       masterVendor == null &&
  //       masterLoc == null &&
  //       masterInventory == null &&
  //       masterReason == null) {
  //     ErrorDialog.showErrorDialog(
  //         context, 'Please download all master file first');
  //   } else if (masterCustomer == null &&
  //       masterVendor == null &&
  //       masterLoc == null &&
  //       masterInventory == null) {
  //     ErrorDialog.showErrorDialog(
  //         context, 'Please download all master file first');
  //   }
  // }
}
