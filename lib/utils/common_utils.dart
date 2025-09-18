// utility class

import 'package:flutter/material.dart';

class CommonUtils {
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  // add utility to get the screen size using MediaQuery
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenWidth(BuildContext context) {
    return getScreenSize(context).width;
  }

  static double screenHeight(BuildContext context) {
    return getScreenSize(context).height;
  }
}
