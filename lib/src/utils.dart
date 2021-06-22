import 'dart:math';

import 'package:ruqqus_dart/src/API.dart';

Uri? routeToUri(String route) => Uri.tryParse(
    route.startsWith(API.host) ? route : '${API.host}${API.apiVersion}$route');

/// Shortens a string to [wrapTo] characters and appends an ellipsis
/// if the string was longer than [wrapTo] characters
String wrapString(String target, [int wrapTo = 30]) {
  final isShortEnough = target.length <= wrapTo;
  return isShortEnough
      ? target
      : (target.substring(0, min(target.length, wrapTo)) + '...');
}
