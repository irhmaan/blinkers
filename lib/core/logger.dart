import 'package:loggy/loggy.dart';

class Logger {
  final Loggy _loggy;

  Logger(String name) : _loggy = Loggy(name) {
    Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));
  }

  void debug(String message) => _loggy.debug(message);
  void info(String message) => _loggy.info(message);
  void warning(String message) => _loggy.warning(message);
  void error(String message) => _loggy.error(message);
}
