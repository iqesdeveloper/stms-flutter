import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stms/config/routes.dart';
import 'package:stms/presentation/widgets/independent/icon_button.dart';

class IncomingView extends StatefulWidget {
  final Function changeView;

  const IncomingView({Key? key, required this.changeView}) : super(key: key);

  @override
  _IncomingViewState createState() => _IncomingViewState();
}

class _IncomingViewState extends State<IncomingView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StmsIconButton(
                  title: 'Receiving',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.purchaseOrder);
                  },
                  icon: FontAwesomeIcons.fileInvoice,
                ),
                StmsIconButton(
                  title: 'PAIV Return',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.paivView);
                  },
                  icon: FontAwesomeIcons.fileAlt,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StmsIconButton(
                  title: 'Sales Return / Cancel Order from Customer',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.srView);
                  },
                  icon: Icons.transform_outlined,
                ),
                StmsIconButton(
                  title: 'Inventory Adjustment (IN)',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.adjustIn);
                  },
                  icon: FontAwesomeIcons.fileImport,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StmsIconButton(
                  title: 'Customer Return',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.returnCustomer);
                  },
                  icon: FontAwesomeIcons.exchangeAlt,
                ),
                StmsIconButton(
                  title: 'Vendor Stock Replacement',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.replaceSupplier);
                  },
                  icon: FontAwesomeIcons.retweet,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StmsIconButton(
                  title: 'Item Modification',
                  onPressed: () {
                    Navigator.of(context).pushNamed(StmsRoutes.itemModify);
                  },
                  icon: FontAwesomeIcons.wrench,
                ),
                // Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
