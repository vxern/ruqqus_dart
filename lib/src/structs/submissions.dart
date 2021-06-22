import 'dart:convert';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/users.dart';

class Post extends Primary {
  final API api;

  SubmissionAuthor? author;
  SubmissionContent? content;
  SubmissionVotes? votes;
  SubmissionFlags? flags;
  GuildName? guildName;
  int? editedAt;

  Post(this.api);

  factory Post.from(API api, Map<String, dynamic> data) {
    print(data);

    final post = Post(api);

    // Primary data
    post.id = data['id'];
    post.fullId = data['fullname'];
    post.link = data['permalink'];
    post.fullLink = '${API.host}${post.link}';
    post.createdAt = data['created_utc'];

    // Post-specific data
    post.author = SubmissionAuthor(
      data['author_name'],
      data.containsKey('author_title')
          ? Title.from(data['author_title'])
          : null,
    );
    post.content = SubmissionContent(
      data['title'],
      Body(data['body'], data['body_html']),
      data['domain'],
      data['url'],
      data['thumb_url'],
      data['embed_url'],
    );
    post.votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    post.flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_deleted'],
      data['is_nsfw'],
      data['is_nsfl'],
      data['is_offensive'],
    );
    post.guildName = GuildName(data['guild_name'], data['original_guild_name']);
    post.editedAt = data['edited_utc'];

    return post;
  }

  Future fetchData(String id) async {
    final response = await api.get('/post/$id');

    if (response == null) {
      api.log.error('Failed to fetch data of post $id');
      return;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    // Primary data
    id = data['id'];
    fullId = data['fullname'];
    link = data['permalink'];
    fullLink = '${API.host}$link';
    createdAt = data['created_utc'];

    // Post-specific data
    author = SubmissionAuthor(
      data['author_name'],
      data.containsKey('author_title')
          ? Title.from(data['author_title'])
          : null,
    );
    content = SubmissionContent(
      data['title'],
      Body(data['body'], data['body_html']),
      data['domain'],
      data['url'],
      data['thumb_url'],
      data['embed_url'],
    );
    votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_deleted'],
      data['is_nsfw'],
      data['is_nsfl'],
      data['is_offensive'],
    );
    guildName = GuildName(data['guild_name'], data['original_guild_name']);
    editedAt = data['edited_utc'];
  }
}

class Comment extends Primary {
  final API api;

  SubmissionAuthor? author;
  Body? body;
  SubmissionVotes? votes;
  SubmissionFlags? flags;
  GuildName? guildName;
  int? editedAt;

  Comment(this.api);

  factory Comment.from(API api, Map<String, dynamic> data) {
    final comment = Comment(api);

    // Primary data
    comment.id = data['id'];
    comment.fullId = data['fullname'];
    comment.link = data['permalink'];
    comment.fullLink = '${API.host}${comment.link}';
    comment.createdAt = data['created_utc'];

    // Comment-specific data
    comment.author = SubmissionAuthor(
      data['author_name'],
      data.containsKey('author_title')
          ? Title.from(data['author_title'])
          : null,
    );
    comment.body = Body(data['body'], data['body_html']);
    comment.votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    comment.flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_deleted'],
      data['is_nsfw'],
      data['is_nsfl'],
      data['is_offensive'],
    );
    comment.guildName = GuildName(
      data['post']['guild_name'],
      data['post']['original_guild_name'],
    );
    comment.editedAt = data['edited_utc'];

    return comment;
  }

  Future fetchData(String id) async {
    final response = await api.get('/comment/$id');

    if (response == null) {
      api.log.error('Failed to fetch data of comment $id');
      return;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    // Primary data
    id = data['id'];
    fullId = data['fullname'];
    link = data['permalink'];
    fullLink = '${API.host}$link';
    createdAt = data['created_utc'];

    // Post-specific data
    author = SubmissionAuthor(
      data['author_name'],
      data.containsKey('author_title')
          ? Title.from(data['author_title'])
          : null,
    );
    body = Body(data['body'], data['body_html']);
    votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_deleted'],
      data['is_nsfw'],
      data['is_nsfl'],
      data['is_offensive'],
    );
    guildName = GuildName(
      data['post']['guild_name'],
      data['post']['original_guild_name'],
    );
    editedAt = data['edited_utc'];
  }
}

class SubmissionFlags {
  final bool isArchived;
  final bool isBanned;
  final bool isDeleted;
  final bool isNsfw;
  final bool isNsfl;
  final bool isOffensive;

  const SubmissionFlags(
    this.isArchived,
    this.isBanned,
    this.isDeleted,
    this.isNsfw,
    this.isNsfl,
    this.isOffensive,
  );
}

class SubmissionContent {
  final String title;
  final Body body;
  final String domain;
  final String url;
  final String? thumbUrl;
  final String? embedUrl;

  const SubmissionContent(
    this.title,
    this.body,
    this.domain,
    this.url,
    this.thumbUrl,
    this.embedUrl,
  );
}

class SubmissionVotes {
  final int score;
  final int upvotes;
  final int downvotes;
  final int? voted;

  const SubmissionVotes(this.score, this.upvotes, this.downvotes, this.voted);
}

class SubmissionAuthor {
  final String username;
  Title? title;

  SubmissionAuthor(this.username, [this.title]);
}

class GuildName {
  final String guildName;
  final String? originalGuildName;

  const GuildName(this.guildName, this.originalGuildName);
}

enum SubmissionType { Post, Comment }
