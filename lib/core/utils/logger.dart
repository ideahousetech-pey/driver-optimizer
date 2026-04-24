import 'dart:developer';

class Logger {
  static void logInfo(String message) {
    log(message, name: 'INFO');
  }

  static void logError(String message) {
    log(message, name: 'ERROR');
  }
}