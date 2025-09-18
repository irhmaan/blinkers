import 'package:loggy/loggy.dart';

class Logger {
  // Singleton instance
  static final Logger _instance = Logger._internal();

  factory Logger() => _instance;

  Logger._internal() {
    // Initialize Loggy only once
    Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));
  }

  final _loggy = Loggy("CVS Logger");

  void debug(String message) => _loggy.debug(message);
  void info(String message) => _loggy.info(message);
  void warning(String message) => _loggy.warning(message);
  void error(String message) => _loggy.error(message);
}
