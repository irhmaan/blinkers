import 'package:cvs/core/app_theme.dart';
import 'package:cvs/presentation/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'CVS'),
    );
  }
}
