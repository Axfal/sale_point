import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import '../../../models/contacts_model.dart';
import '../provider/contacts_provider.dart';
import 'info_row.dart';

class ContactTile extends StatelessWidget {
  final ContactsModel contact;

  const ContactTile({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = (contact.firstName ?? '').isNotEmpty
        ? contact.firstName![0].toUpperCase()
        : (contact.name ?? "N")[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Card(
        color: MyAppColors.scaffoldBgColor,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 1,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Consumer<ContactsProvider>(
            builder: (context, provider, child) {
              final isExpanded = provider.isExpanded(contact.contactId);

              return ExpansionTile(
                onExpansionChanged: (expanded) {
                  provider.toggleExpansion(contact.contactId);
                },
                leading: CircleAvatar(
                  radius: 35.r,
                  backgroundColor: MyAppColors.whiteColor,
                  child: Text(
                    initials,
                    style: TextStyle(color: MyAppColors.blackColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      contact.name ?? "No Name",
                      style: TextStyle(color:MyAppColors.blackColor,fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                    if (contact.email != null && contact.email!.isNotEmpty)
                      Text(
                        contact.email!,
                        style: TextStyle(fontSize: 12.sp, color: MyAppColors.greyColor),
                      ),
                  ],
                ),
                trailing: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.expand_more),
                ),
                childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                children: [
                  const Divider(color: MyAppColors.appBarColor,),
                  InfoRow(icon: Icons.person, label: "Full Name", value: "${contact.firstName ?? ''} ${contact.lastName ?? ''}"),
                  InfoRow(icon: Icons.phone, label: "Phone", value: contact.phone),
                  InfoRow(icon: Icons.email, label: "Email", value: contact.email),
                  InfoRow(icon: Icons.location_on, label: "Address", value: contact.addressLine1),
                  InfoRow(icon: Icons.location_city, label: "City", value: contact.city),
                  InfoRow(icon: Icons.map, label: "Region", value: contact.region),
                  InfoRow(icon: Icons.markunread_mailbox, label: "Postal Code", value: contact.postalCode),
                  InfoRow(icon: Icons.flag, label: "Country", value: contact.country),
                  InfoRow(icon: Icons.info_outline, label: "Status", value: contact.contactStatus),
                  InfoRow(icon: Icons.account_balance, label: "Tax Number", value: contact.taxNumber),
                  InfoRow(icon: Icons.business, label: "Company Number", value: contact.companyNumber),
                  InfoRow(icon: Icons.attach_money, label: "Currency", value: contact.defaultCurrency),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
