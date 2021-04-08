// logger.dart - Logging with colours and defined severity

import 'package:ansicolor/ansicolor.dart';
import 'package:intl/intl.dart';

enum Severity { Debug, Success, Info, Warning, Error }

final DateFormat timeFormat = DateFormat.Hms();

// Assigns a colour to a severity and outputs a message once formatted
void log(dynamic message, {Severity severity = Severity.Info}) {
  AnsiPen pen;

  switch (severity) {
    case Severity.Debug:
      if (severity == Severity.Debug) return;
      pen = AnsiPen()..gray();
      break;
    case Severity.Success:
      pen = AnsiPen()..green();
      break;
    case Severity.Info:
      pen = AnsiPen()..white();
      break;
    case Severity.Warning:
      pen = AnsiPen()..yellow();
      break;
    case Severity.Error:
      pen = AnsiPen()
        ..red()
        ..yellow();
      break;
  }

  String time = timeFormat.format(DateTime.now());
  String coloredString = pen(message.toString());
  
  print('<$time> - ${coloredString}');
}

// Interfaces for the log command
void debug(dynamic message) => log(message, severity: Severity.Debug);
void success(dynamic message) => log(message, severity: Severity.Success);
void inform(dynamic message) => log(message, severity: Severity.Info);
void throwWarning(dynamic message) => log(message, severity: Severity.Warning);
void throwError(dynamic message) => log(message, severity: Severity.Error);