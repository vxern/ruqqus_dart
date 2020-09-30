// structs/guilds.dart - Comprises structs for data about guilds

import 'package:dio/dio.dart';
import 'package:ruqqus_dart/ruqqus_dart.dart';

import 'primary.dart';

class Guild extends Primary {
  final API api;

  String name;
  Body description;
  String color;
  int subscriber_count;
  int guildmaster_count;
  String profile_url;
  String banner_url;
  GuildFlags flags;

  Guild(this.api, this.name);

  void obtainData([Map<String, dynamic> suppliedData]) async {
    Response response;

    // If we already have the data for which a get request would have been otherwise needed, use that
    if (suppliedData != null) {
      response = Response(data: suppliedData);
    } else {
      response = await api.GetRequest('guild/$name');
    }

    name = response.data['name'];
    id = response.data['id'];
    full_id = response.data['fullname'];
    link = response.data['permalink'];
    full_link = '${API.website_link}$link';

    description =
        Body(response.data['description'], response.data['description_html']);
    color = response.data['color'];

    created_at = response.data['created_utc'];
    subscriber_count = response.data['subscriber_count'];
    guildmaster_count = response.data['mods_count'];
    profile_url = response.data['profile_url'].startsWith('/assets')
        ? '$API.website_link${response.data['profile_url']}'
        : response.data['profile_url'];
    banner_url = response.data['banner_url'].startsWith('/assets')
        ? '$API.website_link${response.data['banner_url']}'
        : response.data['banner_url'];
    flags = GuildFlags(response.data['is_banned'], response.data['is_private'],
        response.data['is_restricted'], response.data['over_18']);
  }

  /// Gets and returns a list of 'Post' structs that belong to this guild
  Future<List<Post>> obtainPosts(
      SortType sort_type, int page, int quantity) async {
    var result = <Post>[];

    // Get all posts on a page
    var response = await api.GetRequest('guild/$name/listing', headers: {
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
    return 'Name: $name, id: $id, full_id: $full_id, link: $link, full_link: $full_link, is_banned: ${flags.is_banned}, is_private: ${flags.is_private}, is_restricted: ${flags.is_restricted}, is_over_18: ${flags.over_18}, color: ${color}, subscriber_count: ${subscriber_count}, guildmaster_count: ${guildmaster_count}${description.text.isNotEmpty ? ', description: ${description.text}' : ''}';
  }
}

class GuildName {
  final String guild_name;
  final String original_guild_name;

  GuildName(this.guild_name, this.original_guild_name);
}

class GuildFlags {
  final bool is_banned;
  final bool is_private;
  final bool is_restricted;
  final bool over_18;

  GuildFlags(this.is_banned, this.is_private, this.is_restricted, this.over_18);
}
