import 'package:flutter/material.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:point_of_sales/utils/extensions/sized_box_extension.dart';
import 'package:point_of_sales/ui/home screen/widgets/products/widgets/product_search_delegate.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MyAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MyAppColors.appBarColor,
      title: Image.asset(
        'assets/app_logo/bonope-logo.png',
        height: 40),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        icon: const Icon(
          Icons.menu,
          color: MyAppColors.whiteColor,
        ),
      ),
      actions: [
        Row(
          children: [
            // /// notification button
            // IconButton(
            //     onPressed: (){},
            //     icon: Icon(Icons.notifications,
            //       color: MyAppColors.whiteColor,
            //     )
            // ),
            // SizedBoxExtensions.withWidth(20),
            /// search button
            IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ProductSearchDelegate(),
                  );
                },
                icon: const Icon(
                  Icons.search,
                  color: MyAppColors.whiteColor,
                )),
            SizedBoxExtensions.withWidth(10),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
