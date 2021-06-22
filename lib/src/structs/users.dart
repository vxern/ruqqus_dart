import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/submissions.dart';

/// The `User` data structure, comprising information about a user account
class User extends Primary {
  final API api;

  String? username;
  Title? title;
  Body? bio;
  UserStats? stats;
  String? avatarUrl;
  String? bannerUrl;
  UserFlags? flags;
  List<Badge>? badges;

  User(this.api);

  factory User.from(API api, Map<String, dynamic> data) {
    final user = User(api);

    // Primary data
    user.id = data['id'];
    user.fullId = data['fullname'];
    user.link = data['permalink'];
    user.fullLink = '${API.host}${user.link}';
    user.createdAt = data['created_utc'];

    // User-specific data
    user.username = data['username'];
    if (data['is_deleted'] == '1') {
      user.flags =
          UserFlags(false, false, true, false, 'This user has been deleted');
      return user;
    }
    if (data['is_banned'] == '1') {
      user.flags = UserFlags(true, false, false, false, data['ban_reason']);
      return user;
    }
    if (data.containsKey('title')) {
      user.title = Title.from(data['title']);
    }
    user.bio = Body(data['bio'], data['bio_html']);
    user.stats = UserStats(
      data['post_count'],
      data['post_rep'],
      data['comment_count'],
      data['comment_rep'],
    );
    user.avatarUrl = data['profile_url'].startsWith('/assets')
        ? '$API.website_link${data['profile_url']}'
        : data['profile_url'];
    user.bannerUrl = data['banner_url'].startsWith('/assets')
        ? '$API.website_link${data['banner_url']}'
        : data['banner_url'];
    user.badges = data['badges'].map(
      (badgeRaw) => Badge(
        badgeRaw['name'],
        badgeRaw['text'],
        badgeRaw['url'],
        badgeRaw['icon_url'],
        badgeRaw['created_utc'],
      ),
    );
    user.flags = UserFlags(
      false, // Banned user has already been handled before
      data['is_private'] == '1',
      false, // Deleted user has already been handled before
      data['is_premium'] == '1',
      'User is not banned',
    );

    return user;
  }

  Future fetchData(String username) async {
    final response = await api.get('/user/$username');

    if (response == null) {
      api.log.error('Failed to fetch data of user $username');
      return;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
  }

  /// Gets and returns a list of `Posts` from this `User's` profile
  Future<List<Post>> fetchPosts({
    SortType sortType = SortType.Hot,
    required int page,
    required int quantity,
  }) async {
    // Get posts from listing, determining how the posts should be sorted
    // and which page the listing is to be extracted from
    final response = await api.get('user/$username/listing', headers: {
      'sort': EnumToString.convertToString(sortType).toLowerCase(),
      'page': page,
    });

    if (response == null) {
      return [];
    }

    final body = jsonDecode(response.body);

    // Converts _InternalLinkedHashMap<String, dynamic> to a List<dynamic>
    List<dynamic> rawPosts = Map<String, dynamic>.from(body)['data'];

    return rawPosts.map((rawPost) => Post(api)..fetchData(rawPost)).toList();
  }
}

/// The `User's` title, for example `User123 the Hot` or `User123 the Dumpster Arsonist`
class Title {
  final String name;
  final int id;
  final int kind;
  final String color;

  factory Title.from(Map<String, dynamic> data) {
    return Title(
      data['text'].replace(', ', ''),
      data['id'],
      data['kind'],
      data['color'],
    );
  }

  const Title(this.name, this.id, this.kind, this.color);
}

/// The `User's` stats - how many submissions of each type they have committed and their reputation
class UserStats {
  final int postCount;
  final int postReputation;
  final int commentCount;
  final int commentReputation;

  const UserStats(
    this.postCount,
    this.postReputation,
    this.commentCount,
    this.commentReputation,
  );
}

/// The `User's` flags - used for requesting data
class UserFlags {
  final bool isBanned;
  final bool isPrivate;
  final bool isDeleted;
  final bool isPremium;
  final String banReason;

  const UserFlags(
    this.isBanned,
    this.isPrivate,
    this.isDeleted,
    this.isPremium,
    this.banReason,
  );
}

/// The `User's` badge/s, awarded for certain tasks, such as signing up
/// during alpha or contributing to the Ruqqus source code
class Badge {
  final String name;
  final String description;
  final String url;
  final String iconUrl;
  final int createdAt;

  const Badge(
    this.name,
    this.description,
    this.url,
    this.iconUrl,
    this.createdAt,
  );
}
