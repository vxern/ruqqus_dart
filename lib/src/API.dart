// API.dart - Main file for interacting with the API

import 'dart:io';

import 'package:dio/dio.dart';

import 'client.dart';
import 'logger.dart';
import 'structs/primary.dart';
import 'structs/settings.dart';
import 'structs/users.dart';

/// Provides a nicer interface for calling the API
class API {
  final Client client;

  // HTTP Requests
  final Dio dio = Dio();
  Map<String, dynamic> requestData;

  // Useful links and components of the URI
  static const String website_link = "https://ruqqus.com";
  static const String api_version = "api/v1";
  static const String grant_url = '$website_link/oauth/grant';

  // Controls
  final String user_agent;
  String access_token;

  API(this.client, this.requestData, this.user_agent);

  Future<Response> Get(String path, {Map<String, dynamic> headers}) async {
    return await dio.get(
        // Checks whether the path is an API path, or a URI of its own
        path.contains('$website_link')
            ? path
            : '$website_link/$api_version/$path',
        options: Options(
            // If no headers have been provided, the access token is used instead
            headers: {}
              ..addAll(headers ?? {})
              ..addAll({'Authorization': 'Bearer ${access_token}'})));
  }

  Future<Response> Post(String path,
      {Map<String, dynamic> data, Map<String, dynamic> headers}) async {
    return await dio.post(
        // Checks whether the path is an API path, or a URI of its own
        path.contains('$website_link')
            ? path
            : '$website_link/$api_version/$path',
        // Converts the map into 'formdata' - the data type used by dio
        data: FormData.fromMap(data ?? {}),
        options: Options(
            // If no headers have been provided, the access token is used instead
            headers: headers ?? {'Authorization': 'Bearer ${access_token}'}));
  }

  /// Ruqqus: "Access tokens expire one hour after they are issued.
  /// To maintain ongoing access, you will need to use the refresh token to obtain a new access token."
  void obtainToken() async {
    Response response;

    try {
      // Make a ruqquest to Ruqqus
      response = await Post(API.grant_url,
          data: requestData, headers: {'User-Agent': user_agent});
    } on DioError catch (e) {
      // If not successful, print the error.
      if (!(e.response.statusCode >= 200 && e.response.statusCode <= 299)) {
        throwError('${e.response.statusCode} - ${e.response.statusMessage}');
        sleep(Duration(seconds: 10));
        exit;
      }
    }

    // Build next ruqquest
    access_token = response.data['access_token'];

    // Set up client and start refreshing
    if (!client.isReady) {
      client.isReady = true;
      client.streamController.add('ready');
    }

    Future.delayed(Duration(minutes: 59, seconds: 55), () {
      obtainToken();
    });
  }

  // POST

  /// Submits a post to a guild with the specified title and body
  Future<Response> post(
      {String target_board, String title, String body}) async {
    Response response = await Post('submit',
        data: {'board': target_board, 'title': title, 'body': body});

    if (response.data['guild_name'] == 'general' && target_board != 'general') {
      throwWarning(
          'As the guild name you provided is not valid, the post has been submitted to +general.');
      return response;
    }

    log(Severity.Success, 'Post submitted.');
    return response;
  }

  /// Submits a reply under a parent with the specified body
  Future<Response> reply(
      {SubmissionType type_of_target, String id, String body}) async {
    Response response = await Post('comment', data: {
      'parent_fullname':
          '${type_of_target == SubmissionType.Post ? 't2' : 't3'}_$id',
      'body': body
    });

    log(Severity.Success, 'Reply submitted.');
    return response;
  }

  /// Upvote/downvote, is_up:true = upvote, is_up:false = downvote, is_up:null = remove vote
  Future<Response> vote(
      {SubmissionType type_of_target, String id, bool is_up}) async {
    Response response = await Post(
        'vote/${type_of_target == SubmissionType.Post ? 'post' : 'comment'}/$id/${is_up == null ? 0 : (is_up ? 1 : -1)}');

    log(
        Severity.Success,
        (is_up == null
                ? 'Removed vote from '
                : (is_up ? 'Upvoted ' : 'Downvoted ')) +
            '${type_of_target == SubmissionType.Post ? 'post' : 'comment'}.');
    return response;
  }

  /// Edit post/comment and supplant body with the provided body
  Future<Response> edit(
      {SubmissionType type_of_target, String id, String body}) async {
    Response response = await Post(
        '${type_of_target == SubmissionType.Post ? 'edit_post' : 'edit_comment'}/$id',
        data: {'body': body});

    log(Severity.Success,
        'Edited ${type_of_target == SubmissionType.Post ? 'post' : 'comment'}.');
    return response;
  }

  /// Delete post/comment
  Future<Response> delete({SubmissionType type_of_target, String id}) async {
    Response response = await Post(type_of_target == SubmissionType.Post
        ? 'delete_post/$id'
        : 'delete/comment/$id');

    log(Severity.Success,
        'Deleted ${type_of_target == SubmissionType.Post ? 'post' : 'comment'}.');
    return response;
  }

  /// Update profile settings
  Future<Response> update_profile_settings(
      {ProfileSettings profile_settings}) async {
    Response response = await Post('$website_link/settings/profile', data: {
      'over18': profile_settings.over_18,
      'hide_offensive': profile_settings.hide_offensive,
      'show_nsfl': profile_settings.show_nsfl,
      'filter_nsfw': profile_settings.filter_nsfw,
      'private': profile_settings.private,
      'nofollow': profile_settings.nofollow,
      'bio': profile_settings.bio,
      'title_id': profile_settings.title_id
    });

    log(Severity.Success, 'Updated settings.');
    return response;
  }

  /// Update password
  Future<Response> update_password({UpdatePassword update_password}) async {
    Response response = await Post('$website_link/settings/security', headers: {
      'new_password': update_password.new_password,
      'cnf_password': update_password.new_password,
      'old_password': update_password.old_password
    });

    log(Severity.Success, 'Updated password!');
    return response;
  }

  /// Update email
  Future<Response> update_email({UpdateEmail update_email}) async {
    Response response = await Post('$website_link/settings/security', headers: {
      'new_email': update_email.new_email,
      'password': update_email.password
    });

    log(Severity.Success, 'Updated password!');
    return response;
  }

  /// Enable 2FA
  Future<Response> enable_2fa({Enable2FA enable2fa}) async {
    Response response = await Post('$website_link/settings/security', headers: {
      '2fa_token': enable2fa.two_factor_token,
      '2fa_secret': enable2fa.two_factor_secret,
      'password': enable2fa.password,
    });

    log(Severity.Success, 'Enabled 2-factor authorization successfully!');
    return response;
  }

  /// Disable 2FA
  Future<Response> disable_2fa({Disable2FA disable2fa}) async {
    Response response = await Post('$website_link/settings/security', headers: {
      '2fa_remove': disable2fa.two_factor_token,
      'password': disable2fa.password,
    });

    log(Severity.Success, 'Disabled 2-factor authorization successfully!');
    return response;
  }

  /// Subscribes to a user
  Future<Response> follow({String username}) async {
    Response response = await Post('$website_link/api/follow/$username');

    log(Severity.Success, 'Followed user $username.');
    return response;
  }

  /// Unsubscribes from a user
  Future<Response> unfollow({String username}) async {
    Response response = await Post('$website_link/api/unfollow/$username');

    log(Severity.Success, 'Unfollowed user $username.');
    return response;
  }

  /// Agrees to the ToS
  Future<Response> agree_tos() async {
    Response response = await Post('$website_link/api/agree_tos');

    log(Severity.Success, 'Agreed to ToS.');
    return response;
  }
}
