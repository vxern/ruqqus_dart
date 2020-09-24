import 'package:dio/dio.dart';

// HTTP Requests
final Dio dio = Dio();

/// Provides a nicer interface for calling the API
class API {
  static const String website_link = "https://ruqqus.com";
  static const String api_path = "api/v1";
  static const String grant_url = '$website_link/oauth/grant';

  static Future<Response> Get(String path, Map<String, dynamic> headers) async {
    return await dio.get(path, options: Options(headers: headers));
  }

  static Future<Response> Post(String path, Map<String, dynamic> data,
      Map<String, dynamic> headers) async {
    return await dio.post(path,
        data: FormData.fromMap(data), options: Options(headers: headers));
  }
}
