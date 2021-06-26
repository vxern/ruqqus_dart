# The simplest way to interact with the Ruqqus API

The [ruqqus_dart](https://pub.dev/packages/ruqqus_dart) library can be used to create bots for [Ruqqus](https://ruqqus.com/help/about) - an open-source platform for online communities, free of censorship and moderator abuse by design.

It is currently the most complete and only API wrapper available for Ruqqus in the Dart programming language.

**Feedback is welcomed with open arms** - feel free to contribute by posting an issue, or directly by submitting a pull request.

## Getting started

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
**state** - Your own anti-corss-site-forgery token.
**scope** - What the application is permitted to do with your account. Available scopes: `identity, create, read, update, delete, vote, guildmaster`
To grant your application with the permission to do *everything*, just slot in all the available scopes separated by commas.
**permanent** - Set to `true` if you want the application to have indefinite access to your account.

Once you have pressed '**Authorize**', you will have received a single-use authorization code, which you will be able to exchange for an *access token* - a token which will allow your application to log into and start interacting with Ruqqus using your account.


