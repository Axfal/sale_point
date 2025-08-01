import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/ui/all%20customer/provider/contacts_provider.dart';
import 'package:point_of_sales/ui/all%20customer/wiidgets/contact_tile.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({Key? key}) : super(key: key);

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactsProvider>(context, listen: false).fetchContacts();
    });

    _searchController.addListener(() {
      final query = _searchController.text;
      Provider.of<ContactsProvider>(context, listen: false).searchContacts(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshContacts() async {
    await Provider.of<ContactsProvider>(context, listen: false).fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyAppColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Customer Details",
          style: TextStyle(fontWeight: FontWeight.w500, color: MyAppColors.whiteColor),
        ),
        centerTitle: true,
        backgroundColor: MyAppColors.appBarColor,
        foregroundColor: Colors.black87,

        /// 👇 iOS style back button
        leading: IconButton(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(CupertinoIcons.back, color: MyAppColors.whiteColor),
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ContactsProvider>(
        builder: (context, contactsProvider, _) {
          if (contactsProvider.isLoading) {
            return Center(child: CupertinoActivityIndicator(color: MyAppColors.blackColor));
          }

          return RefreshIndicator(
            onRefresh: _refreshContacts,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: MyAppColors.greyColor),
                        ),
                        filled: true,
                        fillColor: MyAppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Contact Count Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Text(
                  "Total Contacts: ${contactsProvider.contacts.length}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: MyAppColors.blackColor,
                  ),
                ),
              ),

              // Conditional Rendering
              if (contactsProvider.contacts.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No contacts match your search.",
                      style: TextStyle(fontSize: 16.sp, color: MyAppColors.greyColor),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: contactsProvider.contacts.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final contact = contactsProvider.contacts[index];
                      return ContactTile(contact: contact);
                    },
                  ),
                ),
            ],
          ),
          );
        },
      ),
    );
  }
}
