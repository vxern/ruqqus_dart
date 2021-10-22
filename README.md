<div align="center">
    <br/>
    <section>
        <img src="https://i.imgur.com/rdL5hx0.png" width="70%" alt="Logo of ruqqus_dart"/>
    </section>
    <br/>
    <br/>
    <br/>
</div>

The [ruqqus_dart](https://pub.dev/packages/ruqqus_dart) library could have been used to create bots for [Ruqqus](https://ruqqus.com) - an open-source platform for online communities, free of censorship and moderator abuse by design. You ~~go~~ went, Ruqqus! :purple_heart:

Ruqqus has since been shut down, and thus this package has no real use anymore. 😿
It is here to stay, however, as a learning source and as a memory because [ruqqus_dart](https://pub.dev/packages/ruqqus_dart) has been only my second Dart package and project. 🏆

**Feedback was welcome with open arms** - you would have been free to contribute through posting an issue, or directly by submitting a pull request.

## Table of Contents

- [Getting Started](#getting-started)

## Getting Started

To create a simple bot, you would first have needed to have an *authorised application*, which you could have created in the [apps tab](https://ruqqus.com/settings/apps).

In order to have made use of your application, you would have needed to have an account the application can access:

![Accessing Account](https://ruqqus.com/assets/images/illustrations/reader.png)

To do this, you would have needed to log into your desired account, and then prompted the user for authorization.

Copy this link, and modify it with your desired information:

```
https://ruqqus.com/oauth/authorize?client_id=<Client ID here>&redirect_uri=<Redirect URI here>&state=<Your anti-CSRF token>&scope=<Permission scope>&permanent=<true if requesting indefinite access>
```

**client_id** - Your application's identifier, visible in the applications tab in your settings.

**redirect_uri** - Your application's redirect URI, also visible in the applications tab.

**state** - Your own anti-cross-site-forgery token.

**scope** - What the application is permitted to do with your account. Available scopes: `identity, create, read, update, delete, vote, guildmaster`
To grant your application with the permission to do *everything*, just slot in all the available scopes separated by commas.

**permanent** - Set to `true` if you want the application to have indefinite access to your account.

Once you had pressed '**Authorize**', you would have received a single-use authorization code, which you would have been able to exchange for an *access token* - a token which would allow your application to log into and start interacting with Ruqqus using your account.

Then that we were ready to jump into the code, we must have first imported the `ruqqus_dart` package:

```dart
import 'package:ruqqus_dart/ruqqus_dart.dart'
```

:floppy_disk: Now, we were let create a `Client` object using all the necessary data: (This should have been in your `main` function, unless you were already an expert and ain't needed no guidance :sunglasses:)

```dart
final client = Client(
    clientId: '', // Slot in your client ID here
    clientSecret: '', // And your secret token here
    refreshToken: '', // And your refresh token here
    userAgent: 'ruqqus.dart by vxern', // Feel free to use your own user agent :)
    quiet: false // Set to `true` if you do not want to see messages being printed by the library itself
);
```

:muscle: Although we then had a powerful client that knew the arcane arts of summoning posts and replying to comments, it was still quite unable to accomplish anything in particular, as we have not made it authenticate itself:

```dart
client.login();
```

:sparkles: That was much better. However, we still needed to make sure that the client is *ready to listen to us*. We could ensure that it indeed was by creating a listener for the 'ready' event. This functionality was provided by the [event_dart](https://pub.dev/packages/event_dart) package.

```dart
client.on('ready', () async {
    // (continued in the next part)
}
```

:star: Congratulations - You had made a bot that gets authenticated, but then proceeds to do absolutely nothing. We were let put the bot to good use by making our first post.

:grey_exclamation: To prevent triggering the Ruqqus anti-spam protection, the utility `generateRandomString()` function was used to generate a random string of characters.

```dart
final post = await client.api.submitPost(
    targetGuild: 'FormatPlayground',
    title: generateRandomString(addSpaces: true),
    body: generateRandomString(length: 1000, addSpaces: true),
);
```

:tada: You had now made your first post using the `ruqqus_dart` package, and were officially a novice bot-maker. :grin:
