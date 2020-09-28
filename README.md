## Ruqqus.dart
#### A powerful Dart library for interacting with the Ruqqus API.

## Usage

#### A simple usage example:

```dart
import 'package:ruqqus/ruqqus.dart';

void main() async {
  Client client = Client(
      client_id: 'client_id',
      client_secret: 'client_secret',
      refresh_token: 'refresh_token',
      user_agent: 'ruqqus.dart by @vxern');

  client.streamController.stream.listen((event) async {
    switch (event) {
      case 'ready':
        log(Severity.Success, 'ruqqus_dart is ready!');
        await client.api.post(
          target_board: '+formatplayground',
          title: 'This post has been made using ruqqus.dart',
          body: 'https://github.com/devongalat/ruqqus.dart');
        break;
    }
  });
}
```

## Methods

### **Submit post:**
```dart
Future<Response> post({String target_board, String title, String body}) async
```
##### Parameters
- String target_board = The target guild. Default: '+general'
- String title = The title of your post
- String body = The content/body of your post

##### Usage example
```dart
await client.api.post(
  target_board: '+formatplayground',
  title: 'This post has been made using ruqqus.dart',
  body: 'https://github.com/devongalat/ruqqus.dart');
```

### **Submit reply:**
```dart
Future<Response> reply({SubmissionType type_of_target, String id, String body}) async
```
##### Parameters
- [enum] SubmissionType type_of_target = The type of submission you're replying to:
  - SubmissionType.Post
  - SubmissionType.Comment
- String id = The ID of the post / comment you're replying to
- String body = The content/body of your reply

##### Usage examples
```dart
await client.api.reply(
  type_of_target: SubmissionType.Post
  id: '3kz9',
  body: 'This reply to a post has been made using ruqqus.dart');
```
```dart
await client.api.reply(
  type_of_target: SubmissionType.Comment
  id: 'cas6',
  body: 'This reply to a comment has been made using ruqqus.dart');
```

### **Vote on post / comment:**
```dart
Future<Response> vote({SubmissionType type_of_target, String id, bool isUp}) async
```
##### Parameters
- [enum] SubmissionType type_of_target = The type of submission you're voting on:
  - SubmissionType.Post
  - SubmissionType.Comment
- String id = The ID of the post / comment you're voting on
- bool is_up = 
  - true: upvote
  - null: remove vote
  - false: downvote

##### Usage example
```dart
await client.api
  .vote(type_of_target: SubmissionType.Post, id: '3kz9', is_up: true);
```

### **Edit post / comment**
```dart
Future<Response> edit({SubmissionType type_of_target, String id, bool isUp}) async
```
##### Parameters
- [enum] SubmissionType type_of_target = The type of submission you're editing:
  - SubmissionType.Post
  - SubmissionType.Comment
- String id = The ID of the post / comment you're editing
- String body = The content/body of the edit

##### Usage example
```dart
await client.api
  .edit(type_of_target: SubmissionType.Post, id: 'your_post_id', body: 'This is my edit');
```

### **Delete post / comment**
```dart
Future<Response> delete({SubmissionType type_of_target, String id}) async
```
##### Parameters
- [enum] SubmissionType type_of_target = The type of submission you're deleting:
  - SubmissionType.Post
  - SubmissionType.Comment
- String id = The ID of the post / comment you're deleting

##### Usage example
```dart
await client.api
  .delete(type_of_target: SubmissionType.Post, id: 'your_post_id');
```
