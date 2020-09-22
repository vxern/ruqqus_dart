import 'dart:io';

import 'package:eventify/eventify.dart';
import 'package:dio/dio.dart';

import 'logger.dart';

class Client extends EventEmitter {
  static const String grant_url = 'https://ruqqus.com/oauth/grant';

  Dio dio;
  Map<String, String> fetchKeys;
  final client_id;
  final client_secret;
  final code;
  final user_agent;

  bool isOnline;

  Client(this.client_id, this.client_secret, this.code, this.user_agent) {
    dio = Dio();

    fetchKeys = {
      'client_id': client_id,
      'client_secret': client_secret,
      'grant_type': 'code',
      'code': code ?? null
    };
  }

  /// Ruqqus: "Access tokens expire one hour after they are issued.
  /// To maintain ongoing access, you will need to use the refresh token to obtain a new access token."
  void getToken() async {
    Response response = await dio.post(grant_url,
        data: fetchKeys,
        options: Options(headers: {
          'User-Agent': user_agent,
          'Authorization': 'Bearer $client_id'
        }));

    // If the request is not '200 - OK'
    if (response.statusCode != 200) {
      throwError('${response.statusCode} - ${response.statusMessage}');
      sleep(Duration(seconds: 10));
      exit;
    }
  }
}
