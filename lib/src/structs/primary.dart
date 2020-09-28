// structs/primary.dart - Primary structs which are inherited or used by all other major structs

/// All objects which have an ID inherit from this class
class Primary {
  String id;
  String full_id;
  String link;
  String full_link;
  int created_at;
}

/// The text body
class Body {
  final String text;
  final String html;

  Body(this.text, this.html);
}

/// The sorting used for posts and comments
enum SortType { Hot, Top, New, Disputed, Random }

/// The type of submission
enum SubmissionType { Post, Comment }
