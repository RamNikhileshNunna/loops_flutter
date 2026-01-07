import 'dart:developer' as developer;

class AppLogger {
  static void log(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      error: error,
      stackTrace: stackTrace,
      name: 'LoopsApp',
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Severe
      name: 'LoopsApp',
    );
  }
}
