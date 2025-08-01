import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';

class InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;

  const InfoRow({Key? key, this.icon, required this.label, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Icon(icon, size: 16.sp, color: MyAppColors.appBarColor),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$label",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: MyAppColors.blackColor)),
                Text(value!,
                    style: TextStyle(fontSize: 12.sp, color: MyAppColors.greyColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
