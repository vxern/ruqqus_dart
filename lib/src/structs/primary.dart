// structs/primary.dart - Primary structs which are inherited or used by others.

/// All objects which have an ID inherit from this class
class Entity {
  String id;
  String full_id;
  String link;
  String full_link;
  int created_at;
}

enum SortType { Hot, Top, New, Disputed, Random }
