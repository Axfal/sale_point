import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import '../constants/AppTextWidgets.dart';

Widget CustomTextField({
  required TextEditingController controller,
  required bool obscureText,
  required TextInputAction textInputAction,
  required TextInputType keyboardType,
  String? Function(String?)? validator,
  Widget? prefixIcon,
  void Function(String)? onChanged,
  Widget? suffixIcon,
  int? minLines,
  int? maxLines,
  double borderRadius = 12,
  required String hintText,
  String? label,
  FocusNode? focusNode,
  double width = double.infinity,
  double height = double.infinity,
  bool? enabled,
  List<TextInputFormatter>? inputFormatters,
  TextStyle? style, // ✅ Made optional
}) {
  return SizedBox(
    width: width,
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      style: style ?? getRegularStyle(color: MyAppColors.blackColor, fontSize: 12.sp),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      minLines: obscureText ? 1 : minLines,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      cursorColor: MyAppColors.appBarColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: MyAppColors.whiteColor,
        hintText: hintText,
        hintStyle: getLightStyle(color: MyAppColors.greyColor, fontSize: 11.sp),
        labelText: label,
        labelStyle: getSemiBoldStyle(color: MyAppColors.greyColor, fontSize: 10.sp),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: MyAppColors.appBarColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: MyAppColors.appBarColor.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: MyAppColors.appBarColor, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    ),
  );
}
