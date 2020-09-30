// structs/user.dart - File for storing classes used for user data

import 'package:dio/dio.dart';

import '../API.dart';
import '../logger.dart';
import 'submissions.dart';
import 'primary.dart';

// USERS

/// The user class. Comprises info about users
class User extends Primary {
  final API api;

  final String username;
  Title title;
  Body bio;
  UserStats stats;

  String profile_url;
  String banner_url;

  UserFlags flags;
  List<Badge> badges;

  String ban_reason = "User isn't banned";

  User(this.api, this.username);

  void obtainData([Map<String, dynamic> suppliedData]) async {
    Response response;

    // If we already have the data for which a get request would have been otherwise needed, use that
    if (suppliedData != null) {
      response = Response(data: suppliedData);
    } else {
      response = await api.GetRequest('user/$username');
    }

    if (response.data['id'] == null) {
      throwError('Could not obtain id of user $username!');
      return;
    }

    id = response.data['id'];
    full_id = 't1_$id';
    link = response.data['permalink'];
    full_link = '$API.website_link$link';
    flags = UserFlags(false, false);

    if (response.data['is_banned'] == '1') {
      flags.is_banned = true;
      ban_reason = response.data['ban_reason'];
      throwWarning('User $username is banned.');
      if (response.data['is_deleted'] != '1') return;
    }

    if (response.data['is_deleted'] == '1') {
      flags.is_deleted = true;
      throwWarning("User $username's account is deleted.");
      return;
    }

    if (response.data['title'] != null) {
      title = Title(
          response.data['title']['text'].startsWith(',')
              ? response.data['title']['text'].split(', ')[1]
              : response.data['title']['text'],
          response.data['title']['id'].toString(),
          response.data['title']['kind'].toString(),
          response.data['title']['color'].toString());
    }

    bio = Body(response.data['bio'], response.data['bio_html']);

    stats = UserStats(
        int.parse(response.data['post_count'].toString()),
        int.parse(response.data['post_rep'].toString()),
        int.parse(response.data['comment_count'].toString()),
        int.parse(response.data['comment_rep'].toString()));

    profile_url = response.data['profile_url'].startsWith('/assets')
        ? '$API.website_link${response.data['profile_url']}'
        : response.data['profile_url'];
    banner_url = response.data['banner_url'].startsWith('/assets')
        ? '$API.website_link${response.data['banner_url']}'
        : response.data['banner_url'];

    badges = <Badge>[];
    for (dynamic entry in response.data['badges']) {
      badges.add(Badge(
          entry['name'], entry['text'], entry['url'], entry['created_utc']));
    }
  }

  /// Gets and returns a list of 'Post' structs.
  Future<List<Post>> obtainPosts(
      {SortType sort_type = SortType.Hot, int page = 1}) async {
    var result = <Post>[];

    // Get all posts on a page
    var response = await api.GetRequest('user/$username/listing', headers: {
      'sort': sort_type.toString().split('.')[1].toLowerCase(),
      'page': page
    });

    // Converts _InternalLinkedHashMap<String, dynamic> to a List<dynamic> with all the posts
    List<dynamic> posts = Map<String, dynamic>.from(response.data)['data'];

    // Iterates through list of
    for (Map<String, dynamic> entry in posts) {
      var post = Post(api);
      post.obtainData(null, entry);
      result.add(post);
    }

    return result;
  }

  @override
  String toString() {
    return 'Username: $username, id: $id, full_id: $full_id, full_link: $full_link, is_banned: ${flags.is_banned}, is_deleted: ${flags.is_deleted}${title != null ? ', title: ${title.name}' : ''}${bio.text.isNotEmpty ? ', bio: ${bio.text}' : ''}, posts: ${stats.post_count}, post_reputation: ${stats.post_reputation}, comments: ${stats.comment_count}, comment_reputation: ${stats.comment_reputation}, profile_url: $profile_url, banner_url: $banner_url, badges: ${badges.toString()}';
  }
}

/// The user's title, for example ', the Hot' or ', the Dumpster Arsonist'
class Title {
  final String name;
  final String id;
  final String kind;
  final String color;

  Title(this.name, this.id, this.kind, this.color);
}

/// The user's stats: how many posts/comments they've made and their reputation
class UserStats {
  final int post_count;
  final int post_reputation;
  final int comment_count;
  final int comment_reputation;

  UserStats(this.post_count, this.post_reputation, this.comment_count,
      this.comment_reputation);
}

/// The user's flags - used for requesting data
class UserFlags {
  bool is_banned;
  bool is_deleted;

  UserFlags(this.is_banned, this.is_deleted);
}

class Badge {
  final String name;
  final String description;
  final String url;
  final int created_at;

  Badge(this.name, this.description, this.url, this.created_at);
}
