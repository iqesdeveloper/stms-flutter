import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stms/config/routes.dart';
import 'package:stms/presentation/widgets/independent/icon_button.dart';

class OutgoingView extends StatefulWidget {
  final Function changeView;

  const OutgoingView({Key? key, required this.changeView}) : super(key: key);

  @override
  _OutgoingViewState createState() => _OutgoingViewState();
}

class _OutgoingViewState extends State<OutgoingView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StmsIconButton(
                title: 'Sales Invoice',
                onPressed: () {
                  Navigator.of(context).pushNamed(StmsRoutes.siView);
                },
                icon: FontAwesomeIcons.fileInvoice,
              ),
              StmsIconButton(
                title: 'Project Accounting IV (Transfer)',
                onPressed: () {
                  Navigator.of(context).pushNamed(StmsRoutes.paivtView);
                },
                icon: FontAwesomeIcons.fileAlt,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StmsIconButton(
                title: 'Purchase Return',
                onPressed: () {
                  Navigator.of(context).pushNamed(StmsRoutes.prView);
                },
                icon: FontAwesomeIcons.handHolding,
              ),
              StmsIconButton(
                title: 'Inventory Adjustment (OUT)',
                onPressed: () {
                  Navigator.of(context).pushNamed(StmsRoutes.adjustOut);
                },
                icon: FontAwesomeIcons.fileExport,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StmsIconButton(
                title: 'Return to Vendor',
                onPressed: () {
                  Navigator.of(context).pushNamed(StmsRoutes.returnSupplier);
                },
                icon: FontAwesomeIcons.retweet,
              ),
              StmsIconButton(
                title: 'Repaired/Replaced Item to Customer',
                onPressed: () {
                  Navigator.of(context).pushNamed(StmsRoutes.repairCustomer);
                },
                icon: FontAwesomeIcons.exchangeAlt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
