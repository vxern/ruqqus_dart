// API.dart - Main file for interacting with the API

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ruqqus_dart/src/structs/submissions.dart';

import 'client.dart';
import 'logger.dart';
import 'structs/primary.dart';
import 'structs/settings.dart';

/// Provides a nicer interface for calling the API
class API {
  final Client client;

  // HTTP Requests
  final Dio dio = Dio();
  Map<String, dynamic> requestData;

  // Useful links and components of the URI
  static const String website_link = 'https://ruqqus.com';
  static const String api_version = 'api/v1';
  static const String grant_url = '$website_link/oauth/grant';

  // Controls
  final String user_agent;
  String access_token;

  API(this.client, this.requestData, this.user_agent);

  Future<Response> GetRequest(String path,
      {Map<String, dynamic> headers}) async {
    if (path.isEmpty) {
      throwWarning('<PostRequest> Your path is empty.');
      return null;
    }

    try {
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
    } on DioError catch (e) {
      // If not successful, print the error.
      if (!(e.response.statusCode >= 200 && e.response.statusCode <= 299)) {
        throwError('${e.response.statusCode} - ${e.response.statusMessage}');
        exit;
      }
    }

    return null;
  }

  Future<Response> PostRequest(String path,
      {Map<String, dynamic> data, Map<String, dynamic> headers}) async {
    if (path.isEmpty) {
      throwWarning('<PostRequest> Your path is empty.');
      return null;
    }

    try {
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
    } on DioError catch (e) {
      // If not successful, print the error.
      if (!(e.response.statusCode >= 200 && e.response.statusCode <= 299)) {
        throwError('${e.response.statusCode} - ${e.response.statusMessage}');
        exit;
      }
    }

    return null;
  }

  /// Ruqqus: "Access tokens expire one hour after they are issued.
  /// To maintain ongoing access, you will need to use the refresh token to obtain a new access token."
  void obtainToken() async {
    var response = await PostRequest(API.grant_url,
        data: requestData, headers: {'User-Agent': user_agent});

    // Build next ruqquest
    access_token = response.data['access_token'];

    // Set up client and start refreshing
    if (!client.isReady) {
      client.isReady = true;
      client.streamController.add('ready');
    }

    success('<obtainToken> Token obtained!');

    Future.delayed(Duration(minutes: 59, seconds: 55), () {
      obtainToken();
    });
  }

  // POST

  /// Submits a post to a guild with the specified title and body
  Future<Post> post(
      {String target_board = '+general', String title, String body}) async {
    if (title.isEmpty || body.isEmpty) {
      throwWarning('<post> Title or body is missing.');
    }

    var response = await PostRequest('submit',
        data: {'board': target_board, 'title': title, 'body': body});

    var post = Post(this);
    post.obtainData(null, response.data);

    if (response.data['guild_name'] == 'general' &&
        (target_board != 'general' && target_board != '+general')) {
      throwWarning(
          '<post> As the guild name you provided is not valid, the post has been submitted to +general.');
      return post;
    }

    success('<post> Post submitted.');
    return post;
  }

  /// Submits a reply under a parent with the specified body
  Future<Comment> reply(
      {SubmissionType type_of_target, String id, String body}) async {
    var response = await PostRequest('comment', data: {
      'parent_fullname':
          '${type_of_target == SubmissionType.Post ? 't2' : 't3'}_$id',
      'body': body
    });

    var comment = Comment(this);
    await comment.obtainData(null, response.data);

    success('<reply> Reply submitted.');
    return comment;
  }

  /// Upvote/downvote, is_up:true = upvote, is_up:false = downvote, is_up:null = remove vote
  void vote({SubmissionType type_of_target, String id, bool is_up}) async {
    await PostRequest(
        'vote/${type_of_target == SubmissionType.Post ? 'post' : 'comment'}/$id/${is_up == null ? 0 : (is_up ? 1 : -1)}');

    success('<vote> ' +
        (is_up == null
            ? 'Removed vote from '
            : (is_up ? 'Upvoted ' : 'Downvoted ')) +
        '${type_of_target == SubmissionType.Post ? 'post' : 'comment'}.');
  }

  /// Edit post/comment and supplant body with the provided body
  Future<dynamic> edit(
      {SubmissionType type_of_target, String id, String body}) async {
    var response = await PostRequest(
        '${API.website_link}/${type_of_target == SubmissionType.Post ? 'edit_post' : 'edit_comment'}/$id',
        data: {'body': body});

    Post post;
    Comment comment;

    if (type_of_target == SubmissionType.Post) {
      post = Post(this);
      post.obtainData(null, response.data);
    } else {
      comment = Comment(this);
      comment.obtainData(null, response.data);
    }

    success(
        '<edit> Edited ${type_of_target == SubmissionType.Post ? 'post' : 'comment'}.');
    return post ?? comment;
  }

  /// Delete post/comment
  void delete({SubmissionType type_of_target, String id}) async {
    await PostRequest(type_of_target == SubmissionType.Post
        ? 'delete_post/$id'
        : 'delete/comment/$id');

    success(
        'delete > Deleted ${type_of_target == SubmissionType.Post ? 'post' : 'comment'}.');
  }

  /// Update profile settings
  Future<Response> update_profile_settings(
      {ProfileSettings profile_settings}) async {
    var response = await PostRequest('$website_link/settings/profile', data: {
      'over18': profile_settings.over_18,
      'hide_offensive': profile_settings.hide_offensive,
      'show_nsfl': profile_settings.show_nsfl,
      'filter_nsfw': profile_settings.filter_nsfw,
      'private': profile_settings.private,
      'nofollow': profile_settings.nofollow,
      'bio': profile_settings.bio,
      'title_id': profile_settings.title_id
    });

    success('<update_profile_settings> Updated settings.');
    return response;
  }

  /// Update password
  Future<Response> update_password({UpdatePassword update_password}) async {
    var response =
        await PostRequest('$website_link/settings/security', headers: {
      'new_password': update_password.new_password,
      'cnf_password': update_password.new_password,
      'old_password': update_password.old_password
    });

    success('<update_password> Updated password!');
    return response;
  }

  /// Update email
  Future<Response> update_email({UpdateEmail update_email}) async {
    var response = await PostRequest('$website_link/settings/security',
        headers: {
          'new_email': update_email.new_email,
          'password': update_email.password
        });

    success('<update_email> Updated email!');
    return response;
  }

  /// Enable 2FA
  Future<Response> enable_2fa({Enable2FA enable_2fa}) async {
    var response =
        await PostRequest('$website_link/settings/security', headers: {
      '2fa_token': enable_2fa.two_factor_token,
      '2fa_secret': enable_2fa.two_factor_secret,
      'password': enable_2fa.password,
    });

    success('<enable_2fa> Enabled 2-factor authorization successfully!');
    return response;
  }

  /// Disable 2FA
  Future<Response> disable_2fa({Disable2FA disable_2fa}) async {
    var response =
        await PostRequest('$website_link/settings/security', headers: {
      '2fa_remove': disable_2fa.two_factor_token,
      'password': disable_2fa.password,
    });

    success('<disable_2fa> Disabled 2-factor authorization successfully!');
    return response;
  }

  /// Logs all other devices out
  Future<Response> logout_all({String password}) async {
    var response = await PostRequest(
        '$website_link/settings/log_out_all_others',
        headers: {
          'password': password,
        });

    success('<logout_all> All other devices have been logged out');
    return response;
  }

  /// Deletes account. This cannot be undone!
  Future<Response> delete_account(AccountDeletion accountDeletion,
      {AccountDeletion account_deletion}) async {
    var response =
        await PostRequest('$website_link/settings/delete_account', headers: {
      'password': account_deletion.password,
      'delete_reason': account_deletion.delete_reason,
      'twofactor': account_deletion.two_factor_token,
    });

    success('<delete_account> Your account has been deleted. Well done.');
    return response;
  }

  /// Subscribes to a user
  Future<Response> follow({String username}) async {
    var response = await PostRequest('$website_link/api/follow/$username');

    success('<follow> Followed user $username.');
    return response;
  }

  /// Unsubscribes from a user
  Future<Response> unfollow({String username}) async {
    var response = await PostRequest('$website_link/api/unfollow/$username');

    success('<unfollow> Unfollowed user $username.');
    return response;
  }
}
