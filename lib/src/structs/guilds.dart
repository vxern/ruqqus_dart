import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/submissions.dart';
import 'package:ruqqus_dart/src/structs/users.dart';

class Guild extends Primary {
  final API api;

  String? name;
  Body? description;
  String? color;
  int? subscriberCount;
  List<User>? guildmasters;
  String? iconUrl;
  String? bannerUrl;
  GuildFlags? flags;

  Guild(this.api);

  factory Guild.from(API api, Map<String, dynamic> data) {
    final guild = Guild(api);

    // Primary data
    guild.id = data['id'];
    guild.fullId = data['fullname'];
    guild.link = data['permalink'];
    guild.fullLink = '${API.host}${guild.link}';
    guild.createdAt = data['created_utc'];

    // Guild-specific data
    guild.name = data['name'];
    guild.description = Body(
      data['description'],
      data['description_html'],
    );
    guild.color = data['color'];
    guild.subscriberCount = data['subscriber_count'];
    guild.guildmasters = data['guildmasters'].map(
      (guildmasterRaw) => User(api)..fetchData(guildmasterRaw),
    );
    guild.iconUrl = data['profile_url'].startsWith('/assets')
        ? '$API.website_link${data['profile_url']}'
        : data['profile_url'];
    guild.bannerUrl = data['banner_url'].startsWith('/assets')
        ? '$API.website_link${data['banner_url']}'
        : data['banner_url'];
    guild.flags = GuildFlags(
      data['is_banned'],
      data['is_private'],
      data['is_restricted'],
      data['is_siege_protected'],
      data['over_18'],
    );

    return guild;
  }

  Future fetchData(String name) async {
    final response = await api.get('/guild/$name');

    if (response == null) {
      api.log.error('Failed to fetch data of guild $name');
      return;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    // Primary data
    id = data['id'];
    fullId = data['fullname'];
    link = data['permalink'];
    fullLink = '${API.host}$link';
    createdAt = data['created_utc'];

    // Guild-specific data
    name = data['name'];
    description = Body(
      data['description'],
      data['description_html'],
    );
    color = data['color'];
    subscriberCount = data['subscriber_count'];
    guildmasters = data['guildmasters'].map(
      (guildmasterRaw) => User(api)..fetchData(guildmasterRaw.username),
    );
    iconUrl = data['profile_url'].startsWith('/assets')
        ? '$API.website_link${data['profile_url']}'
        : data['profile_url'];
    bannerUrl = data['banner_url'].startsWith('/assets')
        ? '$API.website_link${data['banner_url']}'
        : data['banner_url'];
    flags = GuildFlags(
      data['is_banned'],
      data['is_private'],
      data['is_restricted'],
      data['is_siege_protected'],
      data['over_18'],
    );
  }

  /// Gets and returns a list of `Posts` in this guild
  Future<List<Post>> fetchPosts({
    SortType sortType = SortType.Hot,
    required int page,
    required int quantity,
  }) async {
    // Get posts from listing, determining how the posts should be sorted
    // and which page the listing is to be extracted from
    final response = await api.get('guild/$name/listing', headers: {
      'sort': EnumToString.convertToString(sortType).toLowerCase(),
      'page': page,
    });

    if (response == null) {
      return [];
    }

    final body = jsonDecode(response.body);

    // Converts _InternalLinkedHashMap<String, dynamic> to a List<dynamic> with all the posts
    List<dynamic> rawPosts = Map<String, dynamic>.from(body)['data'];

    return rawPosts.map((rawPost) => Post(api)..fetchData(rawPost)).toList();
  }
}

class GuildFlags {
  final bool isBanned;
  final bool isPrivate;
  final bool isRestricted;
  final bool isSiegeProtected;
  final bool over18;

  GuildFlags(
    this.isBanned,
    this.isPrivate,
    this.isRestricted,
    this.isSiegeProtected,
    this.over18,
  );
}
