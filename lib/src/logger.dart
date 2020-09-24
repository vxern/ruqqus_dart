import 'package:ansicolor/ansicolor.dart';
import 'package:intl/intl.dart';

enum Severity { Debug, Success, Info, Warning, Error }

final timeFormat = DateFormat.Hms();

void log(Severity severity, String message) async {
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
  print('<$time> - ${pen(message)}');
}

void throwError(String message) {
  log(Severity.Error, message);
}
