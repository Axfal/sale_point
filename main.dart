import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/ui/add%20customer/add_customerScreen.dart';
import 'package:point_of_sales/ui/all%20customer/contact_list_screen.dart';
import 'package:point_of_sales/ui/all%20customer/provider/contacts_provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/invoice/providers/bank_provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/provider/category_provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/provider/product_provider.dart';
import 'package:point_of_sales/ui/invoice%20details/providers/payment_provider.dart';
import 'package:point_of_sales/ui/login/provider/login_provider.dart';
import 'package:point_of_sales/ui/home%20screen/bottom_nav/provider/bottom_nav_provider.dart';
import 'package:point_of_sales/ui/home%20screen/home_screen.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/invoice/providers/invoice_provider.dart';
import 'package:point_of_sales/ui/login/login_screen.dart';
import 'package:point_of_sales/ui/sales/provider/sales_provider.dart';
import 'package:point_of_sales/ui/sales/sales_screen.dart';
import 'package:point_of_sales/utils/constants/my_sharePrefs.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await MySharedPrefs().isUserLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            ChangeNotifierProvider(create: (_) => InvoiceProvider()),
            ChangeNotifierProvider(create: (_) => ContactsProvider()),
            ChangeNotifierProvider(create: (_) => SalesProvider()),
            ChangeNotifierProvider(create: (_) => BankProvider()),
            ChangeNotifierProvider(create: (_) => PaymentProvider())
          ],
          child: ScreenUtilInit(
            designSize: const Size(834, 1194),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(1.0)),
                    child: EasyLoading.init()(context, widget),
                  );
                },
                debugShowCheckedModeBanner: false,
                home: isLoggedIn
                    ? HomeScreen(
                        scaffoldKey: GlobalKey<ScaffoldState>(),
                      )
                    : const LoginScreen(),
                // home: SalesScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
