A powerful Dart library for interacting with the Ruqqus API.

## Usage

A simple usage example:

```dart
import 'package:ruqqus/ruqqus.dart';

void main() async {
  Client client = Client(
      'client_id',
      'client_secret',
      'refresh_token', // If you haven't used the library yet, you should use 'code' instead.
      'ruqqus.dart by @vxern'); // User agent

  client.streamController.stream.listen((event) async {
    switch (event) {
      case 'ready':
        log(Severity.Success, 'ruqqus_dart is ready!');
        Response response = await client.api.post(
            '+formatplayground',
            'This post has been made using ruqqus.dart', // Title
            'This post has been made using ruqqus.dart'); // Body
        break;
    }
  });
}
```
