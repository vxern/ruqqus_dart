A powerful Dart library for interacting with the Ruqqus API.

## Usage

A simple usage example:

```dart
import 'package:ruqqus/ruqqus.dart';

void main() async {
  Client client = Client(
      'client_id',
      'client_secret',
      'refresh_token',
      'ruqqus.dart by @vxern');

  client.streamController.stream.listen((event) async {
    switch (event) {
      case 'ready':
        log(Severity.Success, 'ruqqus_dart is ready!');
        Response response = await client.api.post(
            '+formatplayground',
            'This post has been made using ruqqus.dart',
            'This post has been made using ruqqus.dart');
        break;
    }
  });
}
```
