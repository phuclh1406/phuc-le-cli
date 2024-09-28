class Logger {
  static const String tag = '[MyPLCLI]';

  static void info(String message) {
    _logMessage(message, _LogLevel.info);
  }

  static void warn(String message) {
    _logMessage(message, _LogLevel.warn);
  }

  static void error(String message) {
    _logMessage(message, _LogLevel.error);
  }

  static void _logMessage(String message, _LogLevel level) {
    final colorCode = _getColorCode(level);
    final logLevel = level.name.toUpperCase();

    // Log tag in color and message in white
    print('\x1B[${colorCode}m$tag\x1B[0m [$logLevel]: $message');
  }

  static String _getColorCode(_LogLevel level) {
    switch (level) {
      case _LogLevel.info:
        return '32'; // Blue
      case _LogLevel.warn:
        return '33'; // Yellow
      case _LogLevel.error:
        return '31'; // Red
    }
  }
}

enum _LogLevel { info, warn, error }
