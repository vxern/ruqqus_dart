/// Base class for common data structures
abstract class Primary {
  String? id;
  String? fullId;
  String? link;
  String? fullLink;
  int? createdAt;
}

/// Text body containing both plain text and a html representation
class Body {
  final String text;
  final String html;

  Body(this.text, this.html);
}

/// How submissions are sorted when requesting listing data
enum SortType { Hot, Top, New, Disputed, Random }
