/// Base class for common data structures
class Primary {
  /// data['id']
  String? id;

  /// data['fullname']
  String? fullId;

  /// data['permalink']
  String? permalink;

  /// API.host + data['permalink']
  String? fullLink;

  /// data['created_utc']
  int? createdAt;
}

/// Text body containing both plain text and a html representation
class Body {
  /// data['body']
  final String text;

  /// data['body_html']
  final String html;

  Body(this.text, this.html);
}
