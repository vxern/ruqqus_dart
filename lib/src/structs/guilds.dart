// structs/guilds.dart - Comprises structs for data about guilds

import 'package:dio/dio.dart';
import 'package:ruqqus.dart/ruqqus.dart';

import 'primary.dart';

class Guild extends Primary {
  final API api;

  String name;
  Body description;
  String color;
  int subscriber_count;
  int guildmaster_count;
  int profile_url;
  int banner_url;
  GuildFlags flags;

  Guild(this.api);

  void obtainData(String name, [Map<String, dynamic> suppliedData]) async {
    Response response;

    // If we already have the data for which a get request would have been otherwise needed, use that
    if (suppliedData != null)
      response = Response(data: suppliedData);
    else
      response = await api.Get('guild/$name');

    id = response.data['id'];
    full_id = response.data['fullname'];
    link = response.data['permalink'];
    full_link = '${API.website_link}$link';

    this.name = response.data['name'];
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
}

class GuildFlags {
  final bool is_banned;
  final bool is_private;
  final bool is_restricted;
  final bool over_18;

  GuildFlags(this.is_banned, this.is_private, this.is_restricted, this.over_18);
}
