import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/submissions.dart';

/// Data structure comprising information about a user account
class User extends Primary {
  final API api;

  /// data['username']
  String? username;

  /// data['title']
  Title? title;

  /// data['bio'; 'bio_html']
  Body? bio;

  /// data['post_count'; 'post_rep'; 'comment_count'; 'comment_rep']
  UserStats? stats;

  /// data['avatar_url']
  String? avatarUrl;

  /// data['banner_url']
  String? bannerUrl;

  /// data['is_banned'; 'is_private'; 'is_premium'; 'ban_reason']
  UserFlags? flags;

  /// data['badges']
  List<Badge>? badges;

  User(this.api);

  factory User.from(API api, Map<String, dynamic> data) {
    final user = User(api);

    // Primary data
    user.id = data['id'];
    user.fullId = data['fullname'];
    user.permalink = data['permalink'];
    user.fullLink = '${API.host}${user.permalink}';
    user.createdAt = data['created_utc'];

    // User-specific data
    user.username = data['username'];
    if (data['is_banned'] == '1') {
      user.flags = UserFlags(true, false, false, data['ban_reason']);
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
    // TODO: Remove null check when the API gets updated
    user.badges = data['badges']?.map(
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
      data['is_premium'] == '1',
      null,
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

    // Primary data
    id = data['id'];
    fullId = data['fullname'];
    permalink = data['permalink'];
    fullLink = '${API.host}${permalink}';
    createdAt = data['created_utc'];

    // User-specific data
    username = data['username'];
    if (data['is_banned'] == '1') {
      flags = UserFlags(true, false, false, data['ban_reason']);
      return;
    }
    if (data.containsKey('title')) {
      title = Title.from(data['title']);
    }
    bio = Body(data['bio'], data['bio_html']);
    stats = UserStats(
      data['post_count'],
      data['post_rep'],
      data['comment_count'],
      data['comment_rep'],
    );
    avatarUrl = data['profile_url'].startsWith('/assets')
        ? '$API.website_link${data['profile_url']}'
        : data['profile_url'];
    bannerUrl = data['banner_url'].startsWith('/assets')
        ? '$API.website_link${data['banner_url']}'
        : data['banner_url'];
    badges = data['badges']?.map(
      (badgeRaw) => Badge(
        badgeRaw['name'],
        badgeRaw['text'],
        badgeRaw['url'],
        badgeRaw['icon_url'],
        badgeRaw['created_utc'],
      ),
    );
    flags = UserFlags(
      false, // Banned user has already been handled before
      data['is_private'] == '1',
      data['is_premium'] == '1',
      null,
    );
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

/// Data structure for a title that follows a user's name
class Title {
  /// The text content of a title
  final String text;

  /// ID of the title
  final int id;

  /// The rarity / class of a title
  final int kind;

  /// [color] - Colour of the title
  final String color;

  factory Title.from(Map<String, dynamic> data) {
    return Title(
      data['text'].replaceAll(', ', ''),
      data['id'],
      data['kind'],
      data['color'],
    );
  }

  const Title(this.text, this.id, this.kind, this.color);
}

/// Statistics of a user account
class UserStats {
  /// Total number of posts made by the user
  final int? postCount;

  /// Total post score
  final int? postReputation;

  /// Total number of comments made by the user
  final int? commentCount;

  /// Total comment score
  final int? commentReputation;

  const UserStats(
    this.postCount,
    this.postReputation,
    this.commentCount,
    this.commentReputation,
  );
}

/// Indicators of a user account
class UserFlags {
  /// Whether the user is banned
  final bool isBanned;

  /// Whether user's submissions are private
  final bool isPrivate;

  /// Whether the user has a premium account
  final bool isPremium;

  /// If the user is banned, what the reason is
  final String? banReason;

  const UserFlags(
    this.isBanned,
    this.isPrivate,
    this.isPremium,
    this.banReason,
  );
}

/// Data structure for a badge bearable by a user
class Badge {
  /// The 'name' of the badge, or the title
  final String name;

  /// The description of the badge that gives additional information
  final String description;

  /// Additional URL that may point to the origin of the user's award
  final String url;

  /// URL pointing to the badge's image
  final String iconUrl;

  /// Unix timestamp of the badge's creation date
  final int createdAt;

  const Badge(
    this.name,
    this.description,
    this.url,
    this.iconUrl,
    this.createdAt,
  );
}
