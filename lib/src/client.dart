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

  Client({client_id, String client_secret, String refresh_token, user_agent}) {
    requestData = {
      'client_id': client_id,
      'client_secret': client_secret,
      'grant_type': 'refresh',
      'refresh_token': refresh_token ?? null
    };

    api = API(this, requestData, user_agent);
    api.obtainToken();
  }
}
