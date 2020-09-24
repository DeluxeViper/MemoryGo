// Settings
import 'dart:ui';

import 'package:flutter/material.dart';

var durationList = ['15 Mins', '30 Mins', '1 Hr', '2 Hrs'];
var freqList = ['Very low', 'Low', 'Medium', 'High'];

// Colours used in our app
// const kPrimaryColor = const Color(0xFF2BCFFF);
var kPrimaryColor = const Color(0xFF81D4FA);

var appTheme = ThemeData(
  primaryColor: kPrimaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

double getProportionateScreenWidth(BuildContext context, double inputWidth) {
  double screenWidth = MediaQuery.of(context).size.width;

  return (inputWidth / 375.0) * screenWidth;
}

double getProportionateScreenHeight(BuildContext context, double inputWidth) {
  double screenHeight = MediaQuery.of(context).size.height;

  return (inputWidth / 812.0) * screenHeight;
}
