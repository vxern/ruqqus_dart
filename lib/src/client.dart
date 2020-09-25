import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'API.dart';
import 'logger.dart';

class Client {
  // HTTP Request Data
  Map<String, dynamic> requestData;

  // Events
  final StreamController streamController = StreamController.broadcast();

  // Controls
  final String user_agent;
  static String access_token;
  bool isOnline;

  Client(client_id, String client_secret, String code, this.user_agent) {
    requestData = {
      'client_id': client_id,
      'client_secret': client_secret,
      'grant_type': 'refresh',
      'refresh_token': code ?? null
    };

    getToken();
  }

  /// Ruqqus: "Access tokens expire one hour after they are issued.
  /// To maintain ongoing access, you will need to use the refresh token to obtain a new access token."
  void getToken() async {
    Response response;

    try {
      // Make a ruqquest to Ruqqus
      response = await API.Post(
          API.grant_url, requestData, {'User-Agent': user_agent});
    } on DioError catch (e) {
      // If not successful, print the error.
      if (!(e.response.statusCode >= 200 && e.response.statusCode <= 299)) {
        throwError('${e.response.statusCode} - ${e.response.statusMessage}');
        sleep(Duration(seconds: 10));
        exit;
      }
    }

    // Build next ruqquest
    requestData['refresh_token'] = response.data['refresh_token'];
    access_token = response.data['access_token'];

    // Set up client
    //if (requestData['grant_type'] == 'code') {
    requestData['grant_type'] = 'refresh';
    requestData.remove('code');

    isOnline = true;
    streamController.add('ready');
    //}
  }

  void submit(String targetBoard, String title, String body) async {
    Response response = await API.Post(
        'submit', {'board': targetBoard, 'title': title, 'body': body});

    if (response.data['guild_name'] == 'general' && targetBoard != 'general') {
      throwWarning(
          'As the guild name you provided is not valid, the post has been submitted to +general.');
      return;
    }

    log(Severity.Success, 'Post submitted.');
  }

  void comment(String parent, String title, String body) async {
    await API.Post('comment', {'parent_full': 't2_$parent', 'body': body});

    log(Severity.Success, 'Comment submitted.');
  }
}
