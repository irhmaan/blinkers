// ignore depend on todo

import 'dart:io';
import 'package:cvs/core/global.dart';
import 'package:cvs/core/logger.dart';
import 'package:cvs/core/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi' as ffi;

typedef WcslenNative = INT64 Function(ffi.Pointer<ffi.WChar> str);
typedef WcslenDart = int Function(ffi.Pointer<ffi.WChar> str);

class SystemTrayService extends ChangeNotifier
    implements TrayListener, WindowListener {
  final TrayManager _systemTray = TrayManager.instance;

  final logger = Logger("System_Tray_Service");
  Map<String, dynamic> appPreferences = {};

  void initWindowManager() async {
    await windowManager.ensureInitialized();

    const Size fixedSize = Size(800, 600); // your fixed width & height

    WindowOptions windowOptions = const WindowOptions(
      size: fixedSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      // Lock to fixed size
      await windowManager.setSize(fixedSize);
      await windowManager.setMinimumSize(fixedSize);
      await windowManager.setMaximumSize(fixedSize);
      windowManager.addListener(this);
    });
  }

  Future<void> saveOrUpdatePreferences(String key, dynamic data) async {
    final pref = await SharedPrefs.getInstance();

    final configuration = pref.getJson("config") ?? <String, dynamic>{};

    // Update the appPreferences map
    appPreferences[key] = data;

    configuration["config"] = appPreferences;
    logger.info("${configuration["config"]}");
    await pref.setJson("config", configuration);
    logger.info("Updating App Prefs:");
  }

  Future<void> initTray() async {
    // Set tray icon
    logger.info(Global.getAppIcon_2());
    await _systemTray.setIcon(
      Platform.isWindows ? Global.getAppIcon_2() : 'assets/icon/app_icon.png',
    );

    // Define tray menu
    final menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: 'Show'),
        MenuItem(key: 'hide_window', label: 'Hide'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    );

    // Attach context menu
    await _systemTray.setContextMenu(menu);

    // Add tray listener
    _systemTray.addListener(this);
  }

  Future<void> enableDisable() async {
    Global.isMinimizeToTray = !Global.isMinimizeToTray;
    saveOrUpdatePreferences("isMinimizeToTray", Global.isMinimizeToTray);
    windowManager.setPreventClose(Global.isMinimizeToTray);
    logger.info("Minimize to tray: ${Global.isMinimizeToTray}");
  }

  Future<bool> enableAutoStartWindows() async {
    final ffi.DynamicLibrary msvcrt = ffi.DynamicLibrary.open('msvcrt.dll');
    final wcslen = msvcrt.lookupFunction<WcslenNative, WcslenDart>('wcslen');
    if (!Platform.isWindows) {
      logger.info("Only windows is supported right now ! ;/");
      return false;
    }

    final exePath = Platform.resolvedExecutable;

    if (exePath.isEmpty) {
      logger.info("Err: could not resolve executbale path");
      return false;
    }
    final pResult = calloc<INT_PTR>();
    final result = RegOpenKeyEx(
      HKEY_CURRENT_USER,
      TEXT(Global.registryAutoStartKey()),
      0,
      KEY_SET_VALUE,
      pResult,
    );

    if (result != ERROR_SUCCESS) {
      logger.info("Failed to open registry. $result");
      return false;
    }

    final hKey = pResult.value;

    free(pResult);

    final exePathPtr = TEXT('"$exePath"');
    final resultSet = RegSetValueEx(
      hKey,
      TEXT(Global.appName),
      0,
      REG_SZ,
      exePathPtr.cast<ffi.Uint8>(),
      (wcslen(exePathPtr.cast<ffi.WChar>()) + 1) * 2,
    );
    RegCloseKey(hKey);
    try {
      if (resultSet == ERROR_SUCCESS) {
        Global.startWithSystem = !Global.startWithSystem;
        saveOrUpdatePreferences("startWithSystem", Global.startWithSystem);
        logger.info('Successfully registered app for startup');
        return true;
      } else {
        logger.info('Failed to set registry value: Error $resultSet');
        return false;
      }
    } catch (e) {
      logger.info('Error enabling auto-start: $e');
      return false;
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
        break;
      case 'hide_window':
        if (Global.isMinimizeToTray) {
          windowManager.hide();
        }
        break;
      case 'exit':
        _systemTray.removeListener(this);
        windowManager.destroy();
        exit(0);
    }
  }

  @override
  void onTrayIconMouseDown() {
    _systemTray.popUpContextMenu();
  }

  @override
  void onTrayIconMouseUp() {
    // TODO: implement onTrayIconMouseUp
  }

  @override
  void onTrayIconRightMouseDown() {
    // TODO: implement onTrayIconRightMouseDown
  }

  @override
  void onTrayIconRightMouseUp() {
    // TODO: implement onTrayIconRightMouseUp
  }

  @override
  void onWindowBlur() {
    // TODO: implement onWindowBlur
  }

  @override
  void onWindowClose() {
    if (Global.isMinimizeToTray) {
      logger.info("Minimizing to tray");
      windowManager.hide();
      return;
    } else {
      logger.info("Closing the app");
      windowManager.removeListener(this);
      _systemTray.removeListener(this);
      windowManager.destroy();
    }
  }

  @override
  void onWindowDocked() {
    // TODO: implement onWindowDocked
  }

  @override
  void onWindowEnterFullScreen() {
    // TODO: implement onWindowEnterFullScreen
  }

  @override
  void onWindowEvent(String eventName) {
    // TODO: implement onWindowEvent
  }

  @override
  void onWindowFocus() {
    // TODO: implement onWindowFocus
  }

  @override
  void onWindowLeaveFullScreen() {
    // TODO: implement onWindowLeaveFullScreen
  }

  @override
  void onWindowMaximize() {
    // TODO: implement onWindowMaximize
  }

  @override
  void onWindowMinimize() {
    // TODO: implement onWindowMinimize
  }

  @override
  void onWindowMove() {
    // TODO: implement onWindowMove
  }

  @override
  void onWindowMoved() {
    // TODO: implement onWindowMoved
  }

  @override
  void onWindowResize() {
    // TODO: implement onWindowResize
  }

  @override
  void onWindowResized() {
    // TODO: implement onWindowResized
  }

  @override
  void onWindowRestore() {
    // TODO: implement onWindowRestore
  }

  @override
  void onWindowUndocked() {
    // TODO: implement onWindowUndocked
  }

  @override
  void onWindowUnmaximize() {
    // TODO: implement onWindowUnmaximize
  }
}
