// client.dart - The face of ruqqus.dart

import 'dart:async';

import 'API.dart';

class Client {
  // API Handler
  API api;

  // HTTP Request Data
  Map<String, dynamic> requestData;

  // Events
  final StreamController streamController = StreamController.broadcast();

  // Controls
  bool isReady = false;

  Client(
      {String client_id,
      String client_secret,
      String refresh_token,
      String user_agent}) {
    requestData = {
      'client_id': client_id,
      'client_secret': client_secret,
      'grant_type': 'refresh',
      'refresh_token': refresh_token ?? null
    };

    api = API(this, requestData, user_agent);
    api.obtainToken();
  }

  /// Constructs an authentication link
  static Future<String> obtainAuthURL(
      {String client_id,
      String redirect_uri,
      String state,
      List<String> scopes,
      bool is_permanent}) async {
    String scope = scopes.join(',');

    return '${API.website_link}/oauth/authorize?client_id=$client_id&redirect_uri=$redirect_uri&state=${state ?? 'ruqqus'}&scope=$scope&permanent=$is_permanent';
  }
}
