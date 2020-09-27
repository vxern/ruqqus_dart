// structs/submissions.dart - File for storing classes used for post / comment data

import 'package:dio/dio.dart';

import '../API.dart';
import '../logger.dart';
import 'users.dart';
import 'guilds.dart';
import 'primary.dart';

/// The submission class. Comprises info about a post or comment
class Submission extends Primary {
  API api;

  Author author;
  Content content;
  Votes votes;
  int edited_at;
  SubmissionFlags flags;
  GuildName guild_name;

  void _obtainData(String id,
      [Map<String, dynamic> suppliedData,
      SubmissionType submissionType]) async {
    Response response;

    // If we already have the data for which a get request would have been otherwise needed, use that
    if (suppliedData != null)
      response = Response(data: suppliedData);
    else
      response = await api.Get(
          '${submissionType == SubmissionType.Post ? 'post' : 'comment'}/$id',
          headers: {'sort': 'top'});

    if (response.data['id'] == null) {
      throwError(
          'Could not obtain id of ${submissionType == SubmissionType.Post ? 'post' : 'comment'}!');
      return;
    }

    this.id = response.data['id'];
    full_id = response.data['fullname'];
    link = response.data['permalink'];
    full_link = '$API.website_link$link';
    created_at = response.data['created_utc'];
    edited_at = response.data['edited_utc'];

    flags = SubmissionFlags(
        response.data['is_archived'] == '1' ? true : false,
        response.data['is_banned'] == '1' ? true : false,
        response.data['is_deleted'] == '1' ? true : false,
        response.data['is_nsfw'] == '1' ? true : false,
        response.data['is_nsfl'] == '1' ? true : false,
        edited_at > 0);

    author = Author(
        response.data['author'],
        response.data['author_title'] != null
            ? Title(
                response.data['author_title']['text'].startsWith(',')
                    ? response.data['author_title']['text'].split(', ')[1]
                    : response.data['author_title']['text'],
                response.data['author_title']['id'].toString(),
                response.data['author_title']['kind'].toString(),
                response.data['author_title']['color'].toString())
            : null);

    content = Content(
        response.data['title'],
        Body(response.data['body'], response.data['body_html']),
        response.data['domain'],
        response.data['url'],
        response.data['thumb_url'],
        response.data['embed_url']);

    votes = Votes(response.data['score'], response.data['upvotes'],
        response.data['downvotes'], response.data['voted']);

    guild_name = GuildName(
        response.data['guild_name'], response.data['original_guild_name']);
  }
}

class Post extends Submission {
  Post(API api);

  void obtainData(String id, [Map<String, dynamic> suppliedData]) {
    _obtainData(id, suppliedData, SubmissionType.Post);
  }
}

class Comment extends Submission {
  Comment(API api);

  void obtainData(String id, [Map<String, dynamic> suppliedData]) {
    _obtainData(id, suppliedData, SubmissionType.Comment);
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
