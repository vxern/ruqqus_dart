import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprint/sprint.dart';

import 'package:ruqqus_dart/src/client.dart';
import 'package:ruqqus_dart/src/utils.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/settings.dart';
import 'package:ruqqus_dart/src/structs/submissions.dart';

/// Wraps Ruqqus API routes and acts as an interface for interacting with them
class API {
  static const String host = 'https://ruqqus.com';
  static const String apiVersion = '/api/v1';
  static const String grantUrl = '$host/oauth/grant';

  final Sprint log = Sprint('API Caller');

  final Client client;

  final HttpClient httpClient = HttpClient();

  late final Map<String, String> refreshData;

  final String userAgent;

  API(this.client, this.refreshData, this.userAgent, {bool quietMode = false}) {
    log.quietMode = quietMode;
  }

  /// Submits a HTTP `GET` request with the given headers
  Future<http.Response?> get(
    String route, {
    Map<String, dynamic> headers = const {},
  }) async {
    final uri = routeToUri(route);

    if (uri == null) {
      log.warning('Attempted to access an invalid route: ${route}');
      return null;
    }

    final crucialHeaders = <String, dynamic>{
      'Authorization': 'Bearer ${client.accessToken}',
      'User-Agent': userAgent,
      'X-User-Type': 'Bot',
      'X-Library': 'ruqqus.dart',
      'X-Supports': 'auth',
    };

    try {
      return await http.get(
        uri,
        headers: Map<String, String>.from(crucialHeaders..addAll(headers)),
      );
    } on HttpException catch (exception) {
      log.warning(exception.message);
    }
  }

  /// Submits a HTTP `POST` request with the given headers and body
  Future<http.Response?> post(
    String route, {
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> body = const {},
  }) async {
    final uri = routeToUri(route);

    if (uri == null) {
      log.warning('Attempted to access an invalid route: ${route}');
      return null;
    }

    final crucialHeaders = <String, dynamic>{
      'Authorization': 'Bearer ${client.accessToken}',
      'User-Agent': userAgent,
      'X-User-Type': 'Bot',
      'X-Library': 'ruqqus.dart',
      'X-Supports': 'auth',
    };

    try {
      return await http.post(
        uri,
        body: body,
        headers: Map<String, String>.from(crucialHeaders..addAll(headers)),
      );
    } on HttpException catch (exception) {
      log.error(exception.message);
      return null;
    }
  }

  /// Submits a `Post` to a `Guild` with the specified title and body, and an optional url
  Future<Post?> submitPost({
    required String targetGuild,
    required String title,
    required String body,
    String? url,
  }) async {
    final response = await this.post(
      '/submit',
      body: {
        'board': targetGuild,
        'title': title,
        'body': body,
        if (url != null) 'url': url,
      },
    );

    if (response == null) {
      log.error('Failed to submit post in guild $targetGuild');
      return null;
    }

    if (response.body.contains('<title>Redirecting...</title>')) {
      log.error('An identical post already exists:'
          '\nTitle: ${wrapString(title)}'
          '\nBody: ${wrapString(body, 50)}');
      return null;
    }

    log.success('Post submitted');

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    return Post.from(this, responseBody);
  }

  /// Submits a reply under a parent with the specified body
  Future<Comment?> submitReply({
    required SubmissionType parentSubmissionType,
    required String id,
    required String body,
  }) async {
    final response = await post(
      '/comment',
      body: {
        'parent_fullname':
            parentSubmissionType == SubmissionType.Post ? 't2_$id' : 't3_$id',
        'body': body,
      },
    );

    if (response == null) {
      log.error('Failed to submit reply');
      return null;
    }

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (responseBody.containsKey('error')) {
      log.error(responseBody['error']);
      return null;
    }

    log.success('Reply submitted');

    return Comment.from(this, responseBody);
  }

  /// Edit submission by replacing previous content body with a new content body
  Future<Primary?> edit<Submission extends Primary>({
    required SubmissionType parentSubmissionType,
    required String id,
    required String body,
  }) async {
    final response = await this.post(
      parentSubmissionType == SubmissionType.Post
          ? '/edit_post/$id'
          : '/edit_comment/$id',
      body: {
        'body': body,
      },
    );

    if (response == null) {
      log.error('Failed to edit submission');
      return null;
    }

    log.success('Submission edited');

    return parentSubmissionType == SubmissionType.Post
        ? (Post(this)..fetchData(id))
        : (Comment(this)..fetchData(id));
  }

  /// Delete submission
  Future delete({
    required SubmissionType submissionType,
    required String id,
  }) async {
    final response = await post(
      submissionType == SubmissionType.Post
          ? '/delete_post/$id'
          : '/delete/comment/$id',
    );

    if (response == null) {
      log.error('Failed to delete submission');
      return;
    }

    if (response.body.isEmpty) {
      log.success('Deleted submission');
      return;
    }

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (responseBody.containsKey('error')) {
      log.error(responseBody['error']);
      return;
    }
  }

  /// Updates the account's profile settings
  ///
  /// Returns `true` if the profile settings had been updated,
  /// and `false` otherwise
  Future<bool> updateProfileSettings({
    required ProfileSettings profileSettings,
  }) async {
    final response = await post(
      '/settings/profile',
      body: {
        'over18': profileSettings.over18,
        'hide_offensive': profileSettings.hideOffensive,
        'show_nsfl': profileSettings.showNsfl,
        'filter_nsfw': profileSettings.filterNsfw,
        'private': profileSettings.private,
        'nofollow': profileSettings.nofollow,
        'bio': profileSettings.bio,
        'title_id': profileSettings.titleId,
      },
    );

    if (response == null) {
      log.error('Failed to update profile settings');
      return false;
    }

    log.success('Settings updated');

    return true;
  }

  /// Updates the account's password
  ///
  /// Returns `true` if the password had been updated, and `false` otherwise
  Future<bool> updatePassword({
    required UpdatePassword updatePassword,
  }) async {
    final response = await post(
      '/settings/security',
      headers: {
        'new_password': updatePassword.newPassword,
        'cnf_password': updatePassword.newPassword,
        'old_password': updatePassword.oldPassword
      },
    );

    if (response == null) {
      log.error('Failed to update password');
      return false;
    }

    log.success('Password updated');

    return true;
  }

  /// Updates the account's email
  ///
  /// Returns `true` if the email had been updated, and `false` otherwise
  Future<bool> updateEmail({
    required UpdateEmail updateEmail,
  }) async {
    final response = await post(
      '/settings/security',
      headers: {
        'new_email': updateEmail.newEmail,
        'password': updateEmail.password
      },
    );

    if (response == null) {
      log.error('Failed to update email address');
      return false;
    }

    log.success('Email address updated');

    return true;
  }

  /// Enables 2FA on the account
  ///
  /// Returns `true` if 2FA had been enabled, and `false` otherwise
  Future<bool> enable2fa({
    required Enable2FA enable2fa,
  }) async {
    final response = await post(
      '/settings/security',
      headers: {
        '2fa_token': enable2fa.twoFactorToken,
        '2fa_secret': enable2fa.twoFactorSecret,
        'password': enable2fa.password,
      },
    );

    if (response == null) {
      log.error('Failed to enable Two Factor Authorisation');
      return false;
    }

    log.success('Two Factor Authorisation enabled');

    return true;
  }

  /// Disables 2FA on the account
  ///
  /// Returns `true` if 2FA had been disabled, and `false` otherwise
  Future<bool> disable2fa({
    required Disable2FA disable2fa,
  }) async {
    final response = await post(
      '/settings/security',
      headers: {
        '2fa_remove': disable2fa.twoFactorToken,
        'password': disable2fa.password,
      },
    );

    if (response == null) {
      log.error('Failed to disable Two Factor Authorisation');
      return false;
    }

    log.success('Two Factor Authorisation disabled');

    return true;
  }

  /// Logs all other instances out
  ///
  /// Returns `true` if the instances have been logged out, and `false` otherwise
  Future<bool> logoutAll({
    required String password,
  }) async {
    final response = await post(
      '/settings/log_out_all_others',
      headers: {
        'password': password,
      },
    );

    if (response == null) {
      log.error('Failed to disable log out from all other instances');
      return false;
    }

    log.success('All other instances have been logged out');

    return true;
  }

  /// Deletes the account accessing the API. There is no going back!
  ///
  /// Returns `true` if the account has been deleted, and `false` otherwise
  Future<bool> deleteAccount({
    required AccountDeletion accountDeletion,
  }) async {
    final response = await post(
      '/settings/delete_account',
      headers: {
        'password': accountDeletion.password,
        'delete_reason': accountDeletion.deleteReason,
        'twofactor': accountDeletion.twoFactorToken,
      },
    );

    if (response == null) {
      log.error('Failed to delete account');
      return false;
    }

    log.success('Account deleted');

    return true;
  }
}
