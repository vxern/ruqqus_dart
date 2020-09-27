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
            '+formatplayground',
            'This post has been made using ruqqus.dart', // Title
            'https://github.com/devongalat/ruqqus.dart'); // Body
        break;
    }
  });
}
```

## Methods

#### Submit post:
```
Future<Response> post(String target_board, String title, String body)
```
###### Parameters
String target_board = The target guild. Default: '+general'
String title = The title of your post
String body = The content/body of your post

##### Usage example
```
await client.api.post(
  target_board: '+formatplayground',
  title: 'This post has been made using ruqqus.dart',
  body: 'https://github.com/devongalat/ruqqus.dart');
```

#### Submit comment:
```
Future<Response> comment(String parent, String body)
```
###### Parameters
String parent = The ID of the post you're commenting under
String body = The content/body of your comment

##### Usage example
```
await client.api.comment(
  parent: '3kz9',
  body: 'This comment has been made using ruqqus.dart');
```

#### Submit reply:
```
Future<Response> reply(String parent, String body)
```
###### Parameters
String parent = The ID of the comment you're replying to
String body = The content/body of your reply

##### Usage example
```
await client.api.reply(
  parent: 'cas6',
  body: 'This reply has been made using ruqqus.dart');
```
