import 'package:flutter/material.dart';
import 'FontsManager.dart';

TextStyle _getTextStyle(
  double fontSize,
  FontWeight fontWeight,
  Color color,
) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontFamily: "Poppins",
  );
}

TextStyle getRegularStyle({double fontSize = 16, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color);
}

// medium style
TextStyle getMediumStyle({double fontSize = 16, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.medium, color);
}

// medium style
TextStyle getLightStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.light, color);
}

// bold style
TextStyle getBoldStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color);
}

// semibold style
TextStyle getSemiBoldStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color);
}

// bold style
TextStyle getExtraBoldStyle({double fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.extraBold, color);
}
