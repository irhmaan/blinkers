// Global Application settings and configurations

import 'dart:core';

import 'package:cvs/core/logger.dart';
import 'package:cvs/core/shared_prefs.dart';

class Global {
  static getConfig() async {
    final logger = Logger("Global");
    final pref = await SharedPrefs.getInstance();
    final config = pref.getJson("config");
    logger.info("${config?['config']?['isMinimizeToTray']}");
    isMinimizeToTray =
        config?['config']?["isMinimizeToTray"] != null ? true : false;
    allowRunBackground =
        config?['config']?["allowRunBackground"] != null ? true : false;
    startWithSystem =
        config?['config']?["startWithSystem"] != null ? true : false;
  }

  static late bool isMinimizeToTray;
  static late bool allowRunBackground;
  static late bool startWithSystem;

  static String getAppIcon_1() {
    // Return the appropriate app icon based on the platform
    return 'assets/images/eye.icon';
  }

  static String getAppIcon_2() {
    // Return the appropriate app icon based on the platform
    return 'assets/images/eye_shield.ico';
  }

  static String registryAutoStartKey() {
    return r"Software\Microsoft\Windows\CurrentVersion\Run";
  }

  static const String appName = 'CVS';
}
