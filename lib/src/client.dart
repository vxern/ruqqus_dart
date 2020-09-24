import 'dart:io';

import 'package:eventify/eventify.dart';
import 'package:dio/dio.dart';

import 'logger.dart';

class Client extends EventEmitter {
  static const String website_link = "https://ruqqus.com";
  static const String grant_url = '$website_link/grant';

  Dio dio = Dio();

  Map<String, dynamic> requestData;
  Map<String, bool> scopes;
  DateTime nextRefresh;
  bool isOnline;

  Client(client_id, String client_secret, String code, String user_agent) {
    requestData = {
      'client_id': client_id,
      'client_secret': client_secret,
      'grant_type': 'code',
      'code': code ?? null,
      'user_agent': user_agent
    };

    () async => await _getToken();
  }

  /// Ruqqus: "Access tokens expire one hour after they are issued.
  /// To maintain ongoing access, you will need to use the refresh token to obtain a new access token."
  void _getToken() async {
    Response response;

    // Make a ruqquest to Ruqqus
    response = await dio.post(grant_url,
        data: FormData.fromMap(requestData),
        options: Options(headers: {
          'User-Agent': requestData['user_agent'],
          'X-Poster-Type': 'bot'
        }));

    // If not successful, print the error.
    if (!(response.statusCode >= 200 && response.statusCode <= 299)) {
      throwError('${response.statusCode} - ${response.statusMessage}');
      sleep(Duration(seconds: 10));
      exit;
    }

    log(Severity.Debug, response.data.toString());
    // Build next ruqquest
    requestData['access_token'] = response.data['access_token'];
    requestData['refresh_token'] = response.data['refresh_token'];
    nextRefresh = DateTime.parse(response.data[
        'expires_at']); // I'll work out how to set the time back by 5 seconds later

    // Set up client
    if (requestData['grant_type'] == 'code') {
      requestData['grant_type'] = 'refresh';

      // Enable the scopes defined in the response
      response.data.forEach((scope) => {scopes['scope'] = true});

      isOnline = true;
      emit('ready');
    }
  }
}
