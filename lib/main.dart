import 'package:cvs/core/app_theme.dart';
import 'package:cvs/core/tray_manager.dart';
import 'package:cvs/presentation/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final trayService = SystemTrayService();
  await trayService.initTray();
  await trayService.initWindowManager();

  runApp(
    ChangeNotifierProvider<SystemTrayService>.value(
      value: trayService,
      child: const MyApp(),
    ),
  );
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
      home: const Home(),
    );
  }
}
