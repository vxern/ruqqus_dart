<div align="center">
    <br/>
    <section>
        <img src="https://i.imgur.com/rdL5hx0.png" width="70%" alt="Logo of ruqqus_dart"/>
    </section>
    <br/>
    <br/>
    <br/>
</div>

The [ruqqus_dart](https://pub.dev/packages/ruqqus_dart) library can be used to create bots for [Ruqqus](https://ruqqus.com/help/about) - an open-source platform for online communities, free of censorship and moderator abuse by design. You go, Ruqqus! :purple_heart:

**Feedback is welcomed with open arms** - feel free to contribute by posting an issue, or directly by submitting a pull request.

## Table of Contents

- [Getting Started](#getting-started)

## Getting Started

To create a simple bot, you will first need to have an *authorised application*, which you can create in the [apps tab](https://ruqqus.com/settings/apps).

In order to make use of your application, you will need to have an account the application can access:

![Accessing Account](https://ruqqus.com/assets/images/illustrations/reader.png)

To do this, you will need to log into your desired account, and then prompt the user for authorization.

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

Once you have pressed '**Authorize**', you will have received a single-use authorization code, which you will be able to exchange for an *access token* - a token which will allow your application to log into and start interacting with Ruqqus using your account.

Now that we're ready to jump into the code, we must first import the library into our code:

```dart
import 'package:ruqqus_dart/ruqqus_dart.dart'
```

:floppy_disk: Now, let's create a `Client` object using all the necessary data: (This should be in your `main` function, unless you're already an expert and don't need no guidance :sunglasses:)

```dart
final client = Client(
    clientId: '', // Slot in your client ID here
    clientSecret: '', // And your secret token here
    refreshToken: '', // And your refresh token here
    userAgent: 'ruqqus.dart by vxern', // Feel free to use your own user agent :)
    quiet: false // Set to `true` if you do not want to see messages being printed by the library itself
);
```

:muscle: Although we now have a powerful client that has knows the arcane arts of summoning posts and replying to comments, it is still quite unable to accomplish anything, as we have not made it authenticate itself:

```dart
client.login();
```

:sparkles: That's much better. However, we still need to make sure that the client is *ready to listen to us*. We can ensure that it indeed is by creating a listener for the 'ready' event. This functionality is provided by the [event_dart](https://pub.dev/packages/event_dart) library.

```dart
client.on('ready', () async {
    // (continued in the next part)
}
```

:star: Congratulations - You have made a bot that gets authenticated, but then proceeds to do absolutely nothing. Let's put the bot to good use by making our first post.

:grey_exclamation: To prevent triggering the Ruqqus anti-spam protection, the utility `generateRandomString()` function is used to generate a random string of characters.

```dart
final post = await client.api.submitPost(
    targetGuild: 'FormatPlayground',
    title: generateRandomString(addSpaces: true),
    body: generateRandomString(length: 1000, addSpaces: true),
);
```

:tada: You have now made your first post using the `ruqqus_dart` library, and are officially a novice bot-maker. :grin:
