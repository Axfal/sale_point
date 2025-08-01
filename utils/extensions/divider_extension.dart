import 'package:flutter/material.dart';
import '../../../utils/constants/app_colors.dart';

extension CustomDivider on Divider {
  static Divider customDivider({double thickness = 0.3, double height = 1}) {
    return Divider(
      color: MyAppColors.greyColor,
      thickness: thickness,
      height: height,
    );
  }
}
