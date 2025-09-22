import 'package:cvs/core/app_theme.dart';
import 'package:cvs/core/global.dart';
import 'package:cvs/core/tray_manager.dart';
import 'package:cvs/presentation/screens/home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Global.getConfig();
  final trayService = SystemTrayService();
  trayService.initWindowManager();
  await trayService.initTray();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(title: 'CVS'),
    );
  }
}
