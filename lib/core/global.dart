// Global Application settings and configurations

import 'dart:core';

import 'package:cvs/core/logger.dart';
import 'package:cvs/core/shared_prefs.dart';

class Global {
  static late bool isMinimizeToTray;
  static late bool allowRunBackground;
  static late bool startWithSystem;
  static late bool isTimerRunning;

  static Future<void> getConfig() async {
    final logger = Logger("Global");
    final pref = await SharedPrefs.getInstance();
    final config = pref.getJson("config");

    logger.info("${config?.toString()}");

    isMinimizeToTray = config?['config']?["isMinimizeToTray"] ?? false;
    allowRunBackground = config?['config']?["allowRunBackground"] ?? false;
    startWithSystem = config?['config']?["startWithSystem"] ?? false;
    isTimerRunning = config?['config']?["isTimerRunning"] ?? false;
    logger.info("Default1: $isMinimizeToTray");
    logger.info("Default2: $allowRunBackground");
    logger.info("Default3: $startWithSystem");
    logger.info("Default4: $isTimerRunning");
  }

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
