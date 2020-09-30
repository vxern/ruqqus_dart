// client.dart - The face of ruqqus.dart

import 'dart:async';

import 'package:event_dart/event_dart.dart';
import 'package:ruqqus_dart/ruqqus_dart.dart';

import 'API.dart';

class Client extends EventEmitter {
  // API Handler
  API api;

  // HTTP Request Data
  Map<String, dynamic> requestData;

  // Controls
  bool is_ready = false;
  bool is_listening_for_posts = false;
  bool is_listening_for_comments = false;

  // Accumulators
  var accumulate_post_ids = <String>[];
  var accumulate_comment_ids = <String>[];

  Client(
      {String client_id,
      String client_secret,
      String refresh_token,
      String user_agent}) {
    requestData = {
      'client_id': client_id,
      'client_secret': client_secret,
      'grant_type': 'refresh',
      'refresh_token': refresh_token
    };

    api = API(this, requestData, user_agent);
    api.obtainToken();
  }

  /// Begins listening for posts at an interval and emits 'post' when a post appears
  void listenForPosts({Duration interval}) async {
    is_listening_for_posts = true;

    // Get all posts in /all
    var response =
        await api.GetRequest('all/listing', headers: {'sort': 'new'});

    // Converts _InternalLinkedHashMap<String, dynamic> to a List<dynamic> with all the posts
    List<dynamic> posts = Map<String, dynamic>.from(response.data)['data'];

    // Iterates through list of posts
    for (Map<String, dynamic> entry in posts) {
      if (accumulate_post_ids.contains(entry['id'])) {
        continue;
      }

      var post = Post(api);
      post.obtainData(null, entry);
      emit('post', post);
      accumulate_post_ids.add(post.id);
    }

    Future.delayed(interval ?? Duration(minutes: 1), () {
      if (is_listening_for_posts) {
        listenForPosts();
      }
    });
  }

  /// Stops listening for posts
  void stopListeningPosts() {
    is_listening_for_posts = false;
  }

  /// Begins listening for comments at an interval and emits 'comment' when a post appears
  void listenForComments({Duration interval}) async {
    is_listening_for_comments = true;

    // Get all posts in /all
    var response =
        await api.GetRequest('front/comments', headers: {'sort': 'new'});

    // Converts _InternalLinkedHashMap<String, dynamic> to a List<dynamic> with all the posts
    List<dynamic> comments = Map<String, dynamic>.from(response.data)['data'];

    // Iterates through list of posts
    for (Map<String, dynamic> entry in comments) {
      if (accumulate_comment_ids.contains(entry['id'])) {
        continue;
      }

      var comment = Comment(api);
      comment.obtainData(null, entry);
      emit('comment', comment);
      accumulate_comment_ids.add(comment.id);
    }

    Future.delayed(interval ?? Duration(minutes: 1), () {
      if (is_listening_for_comments) {
        listenForComments();
      }
    });
  }

  /// Stops listening for comments
  void stopListeningComments() {
    is_listening_for_posts = false;
  }

  /// Constructs an authentication link
  static Future<String> obtainAuthURL(
      {String client_id,
      String redirect_uri,
      String state,
      List<String> scopes,
      bool is_permanent}) async {
    var scope = scopes.join(',');

    return '${API.website_link}/oauth/authorize?client_id=$client_id&redirect_uri=$redirect_uri&state=${state ?? 'ruqqus'}&scope=$scope&permanent=$is_permanent';
  }
}
