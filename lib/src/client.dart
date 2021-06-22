import 'dart:async';
import 'dart:convert';

import 'package:event_dart/event_dart.dart';
import 'package:sprint/sprint.dart';

import 'package:ruqqus_dart/src/API.dart';
import 'package:ruqqus_dart/src/structs/primary.dart';
import 'package:ruqqus_dart/src/structs/submissions.dart';

class Client with EventEmitter {
  final Sprint log = Sprint('Client');

  late final API api;

  late final Map<String, String> refreshData;

  String? accessToken;

  /// Indicates whether the client is ready to interact with the API
  bool isActive = false;

  /// Minimum interval between read requests
  static const Duration minimumReadInterval = const Duration(minutes: 1);

  /// Minimum interval between write requests
  static const Duration minimumWriteInterval = const Duration(seconds: 3);

  Client({
    required String clientId,
    required String clientSecret,
    required String refreshToken,
    String userAgent = 'Project utilizing ruqqus.dart',
    bool quietMode = false,
  }) {
    refreshData = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'refresh',
      'refresh_token': refreshToken,
    };

    log.quietMode = quietMode;

    api = API(this, refreshData, userAgent, quietMode: quietMode);
  }

  /// Ruqqus: "Access tokens expire one hour after they are issued.
  /// To maintain ongoing access, you will need to use the refresh token to obtain a new access token."
  Future login() async {
    final response = await api.post(API.grantUrl, body: refreshData);

    if (response == null) {
      log.warning('Failed to obtain access token');
      return;
    }

    final body = jsonDecode(response.body);

    accessToken = body['access_token']!;

    if (!isActive) {
      isActive = true;

      emit('ready');
      log.success('The bot is ready to interact with the Ruqqus API');
    } else {
      log.success('Refreshed bot access token');
    }

    Future.delayed(Duration(minutes: 59, seconds: 55), () {
      login();
    });
  }

  /// Begins listening for submissions at with a delay [listeningDelay]
  ///
  /// [listeningDelay] must be longer than 1 minute to prevent flooding the Ruqqus servers
  Stream<Primary> listenForSubmissions<Submission extends Primary>({
    Duration listeningDelay = minimumReadInterval,
    List<String> accumulatedIds = const [],
  }) async* {
    if (listeningDelay.inSeconds < minimumReadInterval.inSeconds) {
      log.warning(
        'The provided interval does not meet the minimum duration of ${minimumReadInterval.inMinutes}'
        ' minute and has been automatically adjusted to it.',
      );
      listeningDelay = minimumReadInterval;
    }

    Timer.periodic(listeningDelay, (timer) async* {
      // Get all entries in /all
      final response = await api.get(
        Submission is Post ? '/all/listing' : '/front/comments',
        headers: {'sort': 'new'},
      );

      if (response == null) {
        log.warning('Failed to fetch most recent submissions');
        return;
      }

      final body = jsonDecode(response.body);

      // Converts _InternalLinkedHashMap<String, dynamic> to a List<dynamic>
      List<dynamic> receivedEntries = Map<String, dynamic>.from(body)['data'];

      // Iterates through the list of entries
      for (Map<String, dynamic> receivedEntry in receivedEntries) {
        // If the entry has already been seen before, ignore it
        if (accumulatedIds.contains(receivedEntry['id'])) {
          continue;
        }

        // Create an entry and stream the response
        final Primary entry = Submission is Post
            ? Post.from(api, receivedEntry)
            : Comment.from(api, receivedEntry);
        yield entry;
        accumulatedIds.add(entry.id!);
      }
    });
  }

  /// Constructs an authentication link
  static String obtainAuthURL({
    required String clientId,
    required String redirectUri,
    String state = 'ruqqus',
    required List<String> scopes,
    required bool isPermanent,
  }) {
    var scope = scopes.join(',');

    return '${API.host}/oauth/authorize'
        '?client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&state=$state'
        '&scope=$scope'
        '&permanent=$isPermanent';
  }
}
