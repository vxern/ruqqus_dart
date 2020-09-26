// structs/submissions.dart - File for storing classes used for post / comment data

import 'package:dio/dio.dart';

import '../API.dart';
import '../logger.dart';
import 'users.dart';
import 'primary.dart';

/// The post class. Comprises info about a post
class Post extends Entity {
  Author author;
  Content content;
  Votes votes;
  int edited_at;
  SubmissionFlags flags;
  GuildName guild_name;

  void obtainData(API api, String id) async {
    Response response = await api.Get('post/$id', {'sort': 'top'});

    if (response.data['id'] == null) {
      throwError('Could not obtain id of post $id!');
      return;
    }

    print(1);

    id = response.data['id'];
    full_id = response.data['fullname'];
    link = response.data['permalink'];
    full_link = '$API.website_link$link';
    created_at = int.parse(response.data['created_utc']);
    edited_at = int.parse(response.data['edited_utc']);

    print(2);

    flags = SubmissionFlags(
        response.data['is_archived'] == '1' ? true : false,
        response.data['is_banned'] == '1' ? true : false,
        response.data['is_deleted'] == '1' ? true : false,
        response.data['is_nsfw'] == '1' ? true : false,
        response.data['is_nsfl'] == '1' ? true : false,
        edited_at > 0);

    print(3);

    author = Author(
        response.data['author'],
        response.data['title'] != null
            ? Title(
                response.data['title']['text'].startsWith(',')
                    ? response.data['title']['text'].split(', ')[1]
                    : response.data['title']['text'],
                response.data['title']['id'].toString(),
                response.data['title']['kind'].toString(),
                response.data['title']['color'].toString())
            : null);

    print(4);

    content = Content(
        response.data['title'],
        Body(response.data['body'], response.data['body_html']),
        response.data['domain'],
        response.data['url'],
        response.data['thumb_url'],
        response.data['embed_url']);

    print(5);

    votes = Votes(
        int.parse(response.data['score']),
        int.parse(response.data['upvotes']),
        int.parse(response.data['downvotes']),
        int.parse(response.data['voted']));

    print(6);

    guild_name = GuildName(
        response.data['guild_name'], response.data['original_guild_name']);

    print(7);
  }
}

/// The post flags
class SubmissionFlags {
  final bool is_archived;
  final bool is_banned;
  final bool is_deleted;
  final bool is_nsfw;
  final bool is_nsfl;
  final bool is_edited;

  SubmissionFlags(this.is_archived, this.is_banned, this.is_deleted,
      this.is_nsfw, this.is_nsfl, this.is_edited);
}

class GuildName {
  final String guild_name;
  final String original_guild_name;

  GuildName(this.guild_name, this.original_guild_name);
}

/// The content of the post
class Content {
  final String title;
  final Body body;
  final String domain;
  final String url;
  final String thumb_url;
  final String embed_url;

  Content(this.title, this.body, this.domain, this.url, this.thumb_url,
      this.embed_url);
}

/// The text body
class Body {
  final String text;
  final String html;

  Body(this.text, this.html);
}

/// The votes of a submission
class Votes {
  final int score;
  final int upvotes;
  final int downvotes;
  final int voted;

  Votes(this.score, this.upvotes, this.downvotes, this.voted);
}

/// The author of the post / comment
class Author {
  final String username;
  final Title title;

  Author(this.username, this.title);
}
