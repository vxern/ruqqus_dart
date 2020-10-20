# Ruqqus.dart [1.0.1]
### A powerful Dart library for interacting with the Ruqqus API.

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

## *METHODS: Client.API*

### **Submit post:**
```dart
Future<Response> post({String target_board, String title, String body}) async
```
##### Parameters
- [String] target_board = The target guild. Default: '+general'
- [String] title = The title of your post
- [String] body = The content/body of your post

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
- [String] id = The ID of the post / comment you're replying to
- [String] body = The content/body of your reply

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

### [ NOT YET ALLOWED BY API ] **Edit post / comment**
```dart
Future<Response> edit({SubmissionType type_of_target, String id, bool isUp}) async
```
##### Parameters
- [enum] SubmissionType type_of_target = The type of submission you're editing:
  - SubmissionType.Post
  - SubmissionType.Comment
- [String] id = The ID of the post / comment you're editing
- [String] body = The content/body of the edit

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
- [String id] = The ID of the post / comment you're deleting

##### Usage example
```dart
await client.api
  .delete(type_of_target: SubmissionType.Post, id: 'your_post_id');
```

### [ NOT YET ALLOWED BY API ] **Follow user (Subscribe to)**
```dart
Future<Response> follow({String username}) async
```
##### Parameters
- [String] username = User to follow

##### Usage example
```dart
await client.api.follow(username: 'vxern');
```

### [ NOT YET ALLOWED BY API ] **Unfollow user (Unsubscribe from)**
```dart
Future<Response> unfollow({String username}) async
```
##### Parameters
- [String] username = User to unfollow

##### Usage example
```dart
await client.api.unfollow(username: 'vxern');
```

### [ NOT YET ALLOWED BY API ] **Update Profile Settings**
```dart
Future<Response> update_profile_settings({ProfileSettings profile_settings}) async
```
##### Parameters
- [class] ProfileSettings profile_settings = Your profile settings
  - [bool] over_18 = Are you over 18?
  - [bool] hide_offensive = Hide offensive content
  - [bool] show_nsfl = Show NSFL ( Not Safe For Life ) content
  - [bool] filter_nsfw = Filter NSFW ( Not Safe For Work ) content
  - [bool] private = You do not want people to see your post / comment history
  - [bool] nofollow = You do not want people to subscribe to you
  - [String] bio = Your profile biography / description
  - [String] title_id = The ID of your title

##### Usage example
```dart
await client.api.update_profile_settings(
    profile_settings: ProfileSettings(
        over_18: true,
        hide_offensive: false,
        show_nsfl: true,
        filter_nsfw: false,
        private: false,
        nofollow: false,
        bio: 'Replacement biography',
        title_id: 'ID of title here'));
```

### [ NOT YET ALLOWED BY API ] **Update Password**
```dart
Future<Response> update_password({UpdatePassword update_password}) async
```
##### Parameters
- [class] UpdatePassword update_password
  - [String] new_password = Your new password
  - [String] old_password = Your old password

##### Usage example
```dart
await client.api.update_password(
    update_password: UpdatePassword(
        new_password: 'chad*&@#\$(1d^', old_password: 'virgin123'));
```

### [ NOT YET ALLOWED BY API ] **Update Email**
```dart
Future<Response> update_email({UpdateEmail update_email}) async
```
##### Parameters
- [class] UpdateEmail update_email
  - [String] new_email = Your new email
  - [String] password = Your password

##### Usage example
```dart
await client.api.update_email(
    update_email: UpdateEmail(
        new_email: 'sample_email@ruqqus.mail', password: 'password'));
```

### [ NOT YET ALLOWED BY API ] **Enable 2FA**
```dart
Future<Response> enable_2fa({Enable2FA enable_2fa}) async
```
##### Parameters
- [class] Enable2FA enable_2fa
  - [String] two_factor_secret = The 2FA secret code
  - [String] two_factor_token = The 2FA token
  - [String] password = Your password

##### Usage example
```dart
await client.api.enable_2fa(
    enable_2fa: Enable2FA(
        two_factor_token: 'token',
        two_factor_secret: 'secret',
        password: 'password'));
```

### [ NOT YET ALLOWED BY API ] **Disable 2FA**
```dart
Future<Response> disable_2fa({Disable2FA disable_2fa}) async
```
##### Parameters
- [class] Disable2FA disable_2fa
  - [String] two_factor_token = The 2FA token
  - [String] password = Your password

##### Usage example
```dart
await client.api.disable_2fa(
    disable_2fa: Disable2FA(
        two_factor_token: 'token',
        password: 'password'));
```

### [ NOT YET ALLOWED BY API ] **Log out of all devices**
```dart
Future<Response> logout_all({String password}) async
```
##### Parameters
- [String] password = Your password

##### Usage example
```dart
await client.api.logout_all(password: 'password');
```

### [ NOT YET ALLOWED BY API ] **Delete account**
###### Why would you even try?

```dart
Future<Response> delete_account({AccountDeletion account_deletion}) async
```
##### Parameters
- [class] AccountDeletion account_deletion
  - [String] password = Your password
  - [String] delete_reason = The reason for deletion of account
  - [String] two_factor_token = If 2FA is enabled, your 2FA token

##### Usage example
```dart
await client.api.delete_account(AccountDeletion('password',
    delete_reason: "ruqqus.dart wasn't good enough",
    two_factor_token: 'token'));
```

## *METHODS: Logger*
###### Provides you with a simple, nice way to log your information.

For debug messages in gray text:
```dart
debug(String message)
```

For success messages in green text:
```dart
success(String message)
```

For info messages in white text:
```dart
inform(String message)
```

For warnings in yellow text:
```dart
throwWarning(String message)
```

For errors in yellow text on red background:
```dart
throwError(String message)
```
