// ignore depend on todo

import 'dart:async' show Timer;
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
import 'package:intl/intl.dart';

typedef WcslenNative = INT64 Function(ffi.Pointer<ffi.WChar> str);
typedef WcslenDart = int Function(ffi.Pointer<ffi.WChar> str);

class SystemTrayService extends ChangeNotifier
    implements TrayListener, WindowListener {
  SystemTrayService() {
    Global.getConfig();
    _checkAutoStartStatus();
  }

  final TrayManager _systemTray = TrayManager.instance;
  final logger = Logger("System_Tray_Service");

  // store info about the application state wether it is minimized or not
  late bool _isMinimizeToTray = Global.isMinimizeToTray;
  bool get isMinimizeToTray => _isMinimizeToTray;

  // _startWithSystem to hold wether auto start is enabled or not.
  late bool _startWithSystem = Global.startWithSystem;
  bool get startWithSystem => _startWithSystem;

  // map to store the user application preferences
  Map<String, dynamic> appPreferences = {};

  bool _isRunningInBackground = false;
  bool get isRunningInBackground => _isRunningInBackground;

  late bool _isTimerRunning = Global.isTimerRunning;
  bool get isTimerRunning => _isTimerRunning;
  int _intervalSeconds = 1200; // for testing purpose
  int get intervalSeconds => _intervalSeconds;
  Timer? _backgroundTimer;

  DateTime? _nextReminderTime;

  bool showHideClearBtn = false;

  Future<void> initWindowManager() async {
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
      Global.startWithSystem
          ? await windowManager.hide()
          : await windowManager.focus();

      // Lock to fixed size
      await windowManager.setSize(fixedSize);
      await windowManager.setMinimumSize(fixedSize);
      await windowManager.setMaximumSize(fixedSize);
      windowManager.addListener(this);
    });

    showHideClearBtn = await checkIfConfigExists();
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

  Future<void> saveOrUpdatePreferences(String key, dynamic value) async {
    final pref = await SharedPrefs.getInstance();

    // Load root config object or create a new one
    final rootConfig = pref.getJson("config") ?? <String, dynamic>{};

    // Get inner config map (nested under "config")
    final innerConfig = (rootConfig["config"] as Map<String, dynamic>?) ?? {};

    // Update the key
    innerConfig[key] = value;

    // Put back into root
    rootConfig["config"] = innerConfig;

    // Save
    await pref.setJson("config", rootConfig);

    logger.info("Updating App Prefs: $rootConfig");
    checkIfConfigExists();
  }

  Future<void> enableDisableMinimizeToTray() async {
    Global.isMinimizeToTray = !Global.isMinimizeToTray;

    _isMinimizeToTray = Global.isMinimizeToTray;
    await windowManager.setPreventClose(_isMinimizeToTray);
    saveOrUpdatePreferences("isMinimizeToTray", _isMinimizeToTray);
    notifyListeners();
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
        _startWithSystem = Global.startWithSystem;
        logger.info('Successfully registered app for startup');
        notifyListeners();
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

  Future<bool> disableAutoStart() async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      final pResult = calloc<INT_PTR>();
      final result = RegOpenKeyEx(
        HKEY_CURRENT_USER,
        TEXT(Global.registryAutoStartKey()),
        0,
        KEY_SET_VALUE,
        pResult,
      );

      if (result != ERROR_SUCCESS) {
        logger.info("Failed to open registry key. Err: $result");
        calloc.free(pResult);
        return false;
      }

      final hKey = pResult.value;
      calloc.free(pResult);

      final resultDelete = RegDeleteValue(hKey, TEXT(Global.appName));
      RegCloseKey(hKey);

      if (resultDelete == ERROR_SUCCESS) {
        logger.info("Success removing Auto start");

        // Flip only once

        // Update global state
        Global.startWithSystem = !Global.startWithSystem;

        // Persist to shared prefs
        await saveOrUpdatePreferences(
          "startWithSystem",
          Global.startWithSystem,
        );

        _startWithSystem = Global.startWithSystem;

        notifyListeners();

        return true;
      } else {
        logger.error("Failed to delete registry value: Err: $resultDelete");
        return false;
      }
    } catch (e) {
      logger.error("Error disabling auto start; $e");
      notifyListeners();
      return false;
    }
  }

  void startBackgroundTimer({int? newIntervalSeconds}) {
    if (newIntervalSeconds != null) {
      _intervalSeconds = newIntervalSeconds;
      notifyListeners();
    }

    // cancel any existing timer if any
    _backgroundTimer?.cancel();

    // start new timer with the current _interval value
    _nextReminderTime = DateTime.now().add(Duration(seconds: _intervalSeconds));
    // Start new timer with the current _intervalSeconds (in seconds)
    _backgroundTimer = Timer.periodic(Duration(seconds: _intervalSeconds), (
      timer,
    ) {
      // Run async restoration in a separate async method
      _nextReminderTime = _nextReminderTime?.add(
        Duration(seconds: _intervalSeconds),
      );
      notifyListeners();
      _restoreApp();
    });

    logger.info(
      "Background timer started (will trigger in ${_intervalSeconds}s)",
    );

    _isRunningInBackground = true;
    _isTimerRunning = true;
    saveOrUpdatePreferences("isTimerRunning", _isTimerRunning);
    notifyListeners();
  }

  Future<void> _restoreApp() async {
    try {
      await windowManager.show();
      await windowManager.maximize();
      await windowManager.setFullScreen(true);
      Size fullScreen = await windowManager.getSize();
      await windowManager.setMaximumSize(fullScreen);
      // await windowManager.setAlwaysOnTop(true);
      logger.info("Timer triggered: App restored to fullscreen");

      // Optionally re-minimize to keep the periodic cycle
      // if (_reminimizeAfterRestore) {
      //   await Future.delayed(Duration(seconds: 5)); // Show for 5 seconds
      //   await windowManager.hide();
      //   _isRunningInBackground = true;
      //   logger.info("App re-minimized to tray for next cycle");
      // } else {
      //   _isRunningInBackground = false;
      // }
      notifyListeners();
    } catch (e) {
      logger.error("Error restoring app: $e");
    }
  }

  void stopBackgroundTimer() {
    logger.info("stopped timer");
    _backgroundTimer?.cancel();
    _isRunningInBackground = false;
    _isTimerRunning = false;
    saveOrUpdatePreferences("isTimerRunning", _isTimerRunning);
    notifyListeners();
  }

  Future<void> _checkAutoStartStatus() async {
    if (!Platform.isWindows) {
      return;
    }

    try {
      final pResult = calloc<INT_PTR>();
      final result = RegOpenKeyEx(
        HKEY_CURRENT_USER,
        TEXT(Global.registryAutoStartKey()),
        0,
        KEY_QUERY_VALUE,
        pResult,
      );

      if (result != ERROR_SUCCESS) {
        logger.warning("Failed to open registry: $result");
        calloc.free(pResult);
        return;
      }
      final hKey = pResult.value;
      calloc.free(pResult);

      final type = calloc<DWORD>();
      final data = calloc<ffi.Uint8>(1024);
      final dataSize = calloc<DWORD>()..value = 1024;

      final queryResult = RegQueryValueEx(
        hKey,
        TEXT(Global.appName),
        ffi.nullptr,
        type,
        data,
        dataSize,
      );

      RegCloseKey(hKey);
      calloc.free(type);
      calloc.free(data);
      calloc.free(dataSize);

      _startWithSystem = queryResult == ERROR_SUCCESS;

      if (_startWithSystem) {
        startBackgroundTimer();
      }
      notifyListeners();
    } catch (e) {
      logger.warning("Error checking auto-start status: $e");
    }
  }

  bool isAppDataCleared = false;

  Future<bool> clearAppData() async {
    try {
      final pref = await SharedPrefs.getInstance();
      final result = await pref.clear();

      hasConfig = !result;
      showHideClearBtn = !result;
      logger.info(
        result ? "Cleared app storage" : "Failed to clear app storage",
      );
      _backgroundTimer = null;
      _isMinimizeToTray = false;
      _isRunningInBackground = false;
      _startWithSystem = false;
      showHideClearBtn = false;
      _isTimerRunning = false;
      notifyListeners();
      return result;
    } catch (e, stack) {
      hasConfig = true;
      showHideClearBtn = true;
      logger.error("Failed to clear app storage: $e\n$stack");
      notifyListeners();
      return false;
    }
  }

  bool hasConfig = false;

  Future<bool> checkIfConfigExists() async {
    final pref = await SharedPrefs.getInstance();
    final data = pref.getJson("config");

    if (data != null) {
      hasConfig = true;
      showHideClearBtn = true;
      logger.info("App storage exists");
    } else {
      hasConfig = false;
      showHideClearBtn = false;
      logger.info("App storage is empty");
    }

    notifyListeners(); // call once after updating
    return hasConfig;
  }

  String showNextRemindTime() {
    if (_intervalSeconds <= 0 || _nextReminderTime == null) {
      return "No reminder set";
    }
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(_nextReminderTime!);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
        break;
      case 'hide_window':
        // if (Global.isMinimizeToTray) {
        windowManager.hide();
        // }
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
    // windowManager.hide();
    return;
  }

  @override
  void onWindowClose() async {
    if (!await windowManager.isPreventClose()) {
      await windowManager.setPreventClose(true);
    }

    if (_isMinimizeToTray) {
      logger.info("Minimizing to tray");
      _isRunningInBackground = true;
      await windowManager.hide();
      return; // important!
    }

    logger.info("Closing the app");
    windowManager.removeListener(this);
    _systemTray.removeListener(this);
    await windowManager.destroy();
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
    logger.info(eventName);
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
    logger.info("Window Minimized Event");
    // _isRunningInBackground = false;
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
