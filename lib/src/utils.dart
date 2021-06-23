import 'dart:math';

import 'package:ruqqus_dart/src/API.dart';

const charList = "abcdefghijklmnopqrstuvwxyz0123456789";
final Random random = Random.secure();

/// Sets a string containing either a URL or route in URI format
Uri? routeToUri(String route) => Uri.tryParse(
    route.startsWith(API.host) ? route : '${API.host}${API.apiVersion}$route');

/// Shortens a string to [wrapTo] characters and appends an ellipsis
/// if the string was longer than [wrapTo] characters
String wrapString(String target, [int wrapTo = 50]) {
  final isShortEnough = target.length <= wrapTo;
  return "'${isShortEnough ? target : target.substring(0, min(target.length, wrapTo))}'";
}

/// Generates a random string of length [length]
String generateRandomString({int length = 32, bool addSpaces = false}) {
  return Iterable.generate(length, (_) {
    if (addSpaces) {
      return random.nextInt(10) >= 8
          ? ' '
          : charList[random.nextInt(charList.length)];
    }

    return charList[random.nextInt(charList.length)];
  }).join('');
}
