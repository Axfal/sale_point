import 'package:flutter/material.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/product_screen.dart';
import 'package:point_of_sales/global%20widgets/my_appbar.dart';
import 'package:point_of_sales/global%20widgets/my_drawer.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/invoice/invoice_card.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  HomeScreen({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      appBar: MyAppBar(scaffoldKey: scaffoldKey),
      drawer: const MyDrawer(),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: ProductScreen(),
                ),
              ],
            ),
          ),
          if (screenWidth > 900)
            Flexible(
              flex: 1,
              child: Container(
                color: MyAppColors.whiteColor,
                child: const InvoiceCard(),
              ),
            ),
        ],
      ),
    );
  }
}
