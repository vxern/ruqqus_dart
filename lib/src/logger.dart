// logger.dart - Logging with colours and defined severity

import 'package:ansicolor/ansicolor.dart';
import 'package:intl/intl.dart';

enum Severity { Debug, Success, Info, Warning, Error }

final timeFormat = DateFormat.Hms();

void log(dynamic message, {Severity severity = Severity.Info}) async {
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

  var time = timeFormat.format(DateTime.now());
  print('<$time> - ${pen(message.toString())}');
}

void debug(dynamic message) {
  log(message, severity: Severity.Debug);
}

void success(dynamic message) {
  log(message, severity: Severity.Success);
}

void inform(dynamic message) {
  log(message, severity: Severity.Info);
}

void throwWarning(dynamic message) {
  log(message, severity: Severity.Warning);
}

void throwError(dynamic message) {
  log(message, severity: Severity.Error);
}
