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
