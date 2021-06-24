import 'dart:convert';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/guilds.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/users.dart';

/// Data structure for a post submission
class Post extends Primary {
  final API api;

  /// data['author']
  User? author;

  /// data['title'; 'body'; 'body_html'; 'domain'; 'url'; 'thumb_url'; 'embed_url']
  PostContent? content;

  /// data['is_archived'; 'is_banned'; 'is_bot'; 'is_deleted'; 'is_distinguished';
  ///      'is_heralded'; 'is_nsfl'; 'is_nsfw'; 'is_offensive'; 'is_pinned']
  SubmissionFlags? flags;

  /// data['award_count'; 'comment_count']
  SubmissionStats? stats;

  /// data['score'; 'upvotes'; 'downvotes'; 'voted']
  SubmissionVotes? votes;

  /// data['guild']
  Guild? guild;

  /// data['herald_guild']
  Guild? heraldGuild;

  /// data['original_guild']
  Guild? originalGuild;

  /// data['edited_utc']
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
    post.content = PostContent(
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
    content = PostContent(
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

/// Data structure for a comment submission
class Comment extends Primary {
  final API api;

  /// data['author']
  User? author;

  /// data['body'; 'body_html']
  Body? body;

  /// data['is_archived'; 'is_banned'; 'is_bot'; 'is_deleted'; 'is_distinguished';
  ///      'is_heralded'; 'is_nsfl'; 'is_nsfw'; 'is_offensive'; 'is_pinned']
  SubmissionFlags? flags;

  /// data['award_count'; 'comment_count']
  SubmissionStats? stats;

  /// data['score'; 'upvotes'; 'downvotes'; 'voted']
  SubmissionVotes? votes;

  /// data['guild']
  Guild? guild;

  /// data['herald_guild']
  Guild? heraldGuild;

  /// data['original_guild']
  Guild? originalGuild;

  /// data['level']
  int? nestingLevel;

  /// data['edited_utc']
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

/// Data structure for the content of a post
class PostContent {
  /// data['title']
  final String title;

  /// data['body'; 'body_html']
  final Body body;

  /// data['domain']
  final String domain;

  /// data['url']
  final String url;

  /// data['thumb_url']
  final String? thumbUrl;

  /// data['embed_url']
  final String? embedUrl;

  const PostContent(
    this.title,
    this.body,
    this.domain,
    this.url,
    this.thumbUrl,
    this.embedUrl,
  );
}

/// Indicators of a submission
class SubmissionFlags {
  /// data['is_archived']
  final bool isArchived;

  /// data['is_banned']
  final bool isBanned;

  /// data['is_bot']
  final bool isBot;

  /// data['is_deleted']
  final bool isDeleted;

  /// data['is_distinguished']
  final bool isDistinguished;

  /// data['is_heralded']
  final bool isHeralded;

  /// data['is_nsfl']
  final bool isNsfl;

  /// data['is_nsfw']
  final bool isNsfw;

  /// data['is_offensive']
  final bool isOffensive;

  /// data['is_pinned']
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

/// Statistics of votes on a submission
class SubmissionVotes {
  /// data['score']
  final int score;

  /// data['upvotes']
  final int upvotes;

  /// data['downvotes']
  final int downvotes;

  /// data['voted']
  final int voted;

  const SubmissionVotes(this.score, this.upvotes, this.downvotes, this.voted);
}

/// Statistics of a submission
class SubmissionStats {
  /// data['award_count']
  final int awardCount;

  /// data['comment_count']
  final int?
      commentCount; // TODO: Remove possible null value when the API gets updated

  const SubmissionStats(this.awardCount, this.commentCount);
}

/// The type of submission
enum SubmissionType { Post, Comment }

/// How submissions are sorted when requesting listing data
enum SortType { Hot, Top, New, Disputed, Random }
