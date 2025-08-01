import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/ui/add%20customer/add_customerScreen.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import '../ui/all customer/contact_list_screen.dart';
import '../ui/login/provider/login_provider.dart';
import '../ui/login/login_screen.dart';
import '../../models/user_model.dart';
import '../ui/sales/sales_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  /// Handle logout process
  Future<void> _handleLogout(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    // Close the drawer first
    Navigator.pop(context);

    // Perform logout
    final success = await loginProvider.userLogout();

    if (success) {
      // Navigate to login screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          final UserModel? user = loginProvider.user;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: MyAppColors.appBarColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: const TextStyle(
                        color: MyAppColors.whiteColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'Welcome to the POS',
                      style: const TextStyle(
                        color: MyAppColors.whiteColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔹 General Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "General",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildListTile(
                icon: Icons.attach_money,
                title: 'Sales',
                onTap: () {
                  Navigator.pop(context); // First close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesScreen()),
                  );
                },
              ),
              // _buildListTile(
              //   icon: Icons.receipt,
              //   title: 'Receipts',
              //   onTap: () => Navigator.pop(context),
              // ),

              /// 🧑 Customers Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Customers",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildListTile(
                icon: Icons.person_add,
                title: 'Add Customer',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCustomerScreen()));
                },
              ),
              _buildListTile(
                icon: Icons.group,
                title: 'All Customers',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContactsListScreen()));
                },
              ),

              /// ⚙️ Settings & Logout
              const Divider(),
              // _buildListTile(
              //   icon: Icons.settings,
              //   title: 'Settings',
              //   onTap: () => Navigator.pop(context),
              // ),
              _buildListTile(
                icon: Icons.logout,
                title: 'Logout',
                textColor: MyAppColors.blackColor,
                iconColor: MyAppColors.appBarColor,
                onTap: () => _handleLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Reusable ListTile builder to keep the widget tree clean
  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color iconColor = MyAppColors.appBarColor,
    Color textColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
