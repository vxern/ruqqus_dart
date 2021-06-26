import 'package:ruqqus_dart/ruqqus_dart.dart';

void main() async {
  final client = Client(
    clientId: 'client_id',
    clientSecret: 'client_secret',
    refreshToken: 'refresh_token',
    userAgent: 'ruqqus.dart by @vxern',
  );

  client.on('ready', () async {
    final post = await client.api.submitPost(
      targetGuild: 'FormatPlayground',
      title: generateRandomString(),
      body: 'Title ^',
    );

    final comment = await client.api.submitReply(
      parentSubmissionType: SubmissionType.Post,
      id: post!.id!,
      body: generateRandomString(length: 1000, addSpaces: true),
    );

    await client.api.submitReply(
      parentSubmissionType: SubmissionType.Comment,
      id: comment!.id!,
      body: generateRandomString(length: 1000, addSpaces: true),
    );
  });

  client.login();
}
