import 'dart:convert';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/guilds.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/users.dart';

class Post extends Primary {
  final API api;

  User? author;
  SubmissionContent? content;
  SubmissionFlags? flags;
  SubmissionStats? stats;
  SubmissionVotes? votes;
  Guild? guild;
  Guild? heraldGuild;
  Guild? originalGuild;
  int? editedAt;

  Post(this.api);

  factory Post.from(API api, Map<String, dynamic> data) {
    final post = Post(api);

    // Primary data
    post.id = data['id'];
    post.fullId = data['fullname'];
    post.permalink = data['permalink'];
    post.fullLink = '${API.host}${post.permalink}';
    post.createdAt = data['created_utc'];

    // Post-specific data
    post.author = User.from(api, data['author']);
    post.content = SubmissionContent(
      data['title'],
      Body(data['body'], data['body_html']),
      data['domain'],
      data['url'],
      data['thumb_url'],
      data['embed_url'],
    );
    post.flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_bot'],
      data['is_deleted'],
      data['is_distinguished'],
      data['is_heralded'],
      data['is_nsfl'],
      data['is_nsfw'],
      data['is_offensive'],
      data['is_pinned'],
    );
    post.stats = SubmissionStats(data['award_count'], data['comment_count']);
    post.votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    post.guild = Guild.from(api, data['guild']);
    post.heraldGuild = data['herald_guild'] != null
        ? Guild.from(api, data['herald_guild'])
        : null;
    post.originalGuild = data['original_guild'] != null
        ? Guild.from(api, data['original_guild'])
        : null;
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
    permalink = data['permalink'];
    fullLink = '${API.host}${permalink}';
    createdAt = data['created_utc'];

    // Post-specific data
    author = User.from(api, data['author']);
    content = SubmissionContent(
      data['title'],
      Body(data['body'], data['body_html']),
      data['domain'],
      data['url'],
      data['thumb_url'],
      data['embed_url'],
    );
    flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_bot'],
      data['is_deleted'],
      data['is_distinguished'],
      data['is_heralded'],
      data['is_nsfl'],
      data['is_nsfw'],
      data['is_offensive'],
      data['is_pinned'],
    );
    stats = SubmissionStats(data['award_count'], data['comment_count']);
    votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    guild = Guild.from(api, data['guild']);
    heraldGuild = data['herald_guild'] != null
        ? Guild.from(api, data['herald_guild'])
        : null;
    originalGuild = data['original_guild'] != null
        ? Guild.from(api, data['original_guild'])
        : null;
    editedAt = data['edited_utc'];
  }
}

class Comment extends Primary {
  final API api;

  User? author;
  Body? body;
  SubmissionFlags? flags;
  SubmissionStats? stats;
  SubmissionVotes? votes;
  Guild? guild;
  Guild? heraldGuild;
  Guild? originalGuild;
  int? nestingLevel;
  int? editedAt;

  Comment(this.api);

  factory Comment.from(API api, Map<String, dynamic> data) {
    final comment = Comment(api);

    // Primary data
    comment.id = data['id'];
    comment.fullId = data['fullname'];
    comment.permalink = data['permalink'];
    comment.fullLink = '${API.host}${comment.permalink}';
    comment.createdAt = data['created_utc'];

    // Comment-specific data
    comment.author = User.from(api, data['author']);
    comment.body = Body(data['body'], data['body_html']);
    comment.flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_bot'],
      data['is_deleted'],
      data['is_distinguished'],
      data['is_heralded'],
      data['is_nsfl'],
      data['is_nsfw'],
      data['is_offensive'],
      data['is_pinned'],
    );
    comment.stats = SubmissionStats(data['award_count'], data['comment_count']);
    comment.votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    comment.guild = Guild.from(api, data['guild']);
    comment.heraldGuild = data['herald_guild'] != null
        ? Guild.from(api, data['herald_guild'])
        : null;
    comment.originalGuild = data['original_guild'] != null
        ? Guild.from(api, data['original_guild'])
        : null;
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
    permalink = data['permalink'];
    fullLink = '${API.host}${permalink}';
    createdAt = data['created_utc'];

    // Comment-specific data
    author = User.from(api, data['author']);
    body = Body(data['body'], data['body_html']);
    flags = SubmissionFlags(
      data['is_archived'],
      data['is_banned'],
      data['is_bot'],
      data['is_deleted'],
      data['is_distinguished'],
      data['is_heralded'],
      data['is_nsfl'],
      data['is_nsfw'],
      data['is_offensive'],
      data['is_pinned'],
    );
    stats = SubmissionStats(data['award_count'], data['comment_count']);
    votes = SubmissionVotes(
      data['score'],
      data['upvotes'],
      data['downvotes'],
      data['voted'],
    );
    guild = Guild.from(api, data['guild']);
    heraldGuild = data['herald_guild'] != null
        ? Guild.from(api, data['herald_guild'])
        : null;
    originalGuild = data['original_guild'] != null
        ? Guild.from(api, data['original_guild'])
        : null;
    editedAt = data['edited_utc'];
  }
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

class SubmissionFlags {
  final bool isArchived;
  final bool isBanned;
  final bool isBot;
  final bool isDeleted;
  final bool isDistinguished;
  final bool isHeralded;
  final bool isNsfl;
  final bool isNsfw;
  final bool isOffensive;
  final bool?
      isPinned; // TODO: Remove possible null value when the API gets updated

  const SubmissionFlags(
    this.isArchived,
    this.isBanned,
    this.isBot,
    this.isDeleted,
    this.isDistinguished,
    this.isHeralded,
    this.isNsfl,
    this.isNsfw,
    this.isOffensive,
    this.isPinned,
  );
}

class SubmissionVotes {
  final int score;
  final int upvotes;
  final int downvotes;
  final int voted;

  const SubmissionVotes(this.score, this.upvotes, this.downvotes, this.voted);
}

class SubmissionStats {
  final int awardCount;
  final int?
      commentCount; // TODO: Remove possible null value when the API gets updated

  const SubmissionStats(this.awardCount, this.commentCount);
}

enum SubmissionType { Post, Comment }
