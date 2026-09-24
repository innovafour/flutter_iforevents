import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

/// Captures what the SDK actually puts on the wire.
///
/// These details are worth a real socket rather than a mock: they were wrong
/// at once, and they are invisible to a unit test that stops at the
/// integration's public surface. The API reads the user id from `X-User-Id`
/// and rejects nothing when it is missing — it files the event under an
/// address-derived profile — so a wrong header name fails silently in
/// production.
class _CapturedRequest {
  _CapturedRequest({
    required this.headers,
    required this.body,
    required this.path,
  });

  final Map<String, String> headers;
  final Map<String, dynamic> body;
  final String path;
}

void main() {
  late HttpServer server;
  late List<_CapturedRequest> captured;
  late String baseUrl;
  late Directory storageDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // The test binding installs an HttpOverrides that answers every request
    // with a 400 and never opens a socket. These tests exist to inspect the
    // bytes the SDK actually writes, so hand the real client back.
    HttpOverrides.global = null;

    // The integration persists the user uuid through GetStorage, which reaches
    // for path_provider. Point it at a scratch directory instead.
    storageDir = await Directory.systemTemp.createTemp('iforevents_test');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => storageDir.path,
        );

    await GetStorage.init();
  });

  tearDownAll(() async {
    await storageDir.delete(recursive: true);
  });

  setUp(() async {
    captured = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    // The integration appends `/v1`, so the base URL stops at the host.
    baseUrl = 'http://${server.address.host}:${server.port}';

    server.listen((request) async {
      final raw = await utf8.decoder.bind(request).join();

      captured.add(
        _CapturedRequest(
          headers: {
            for (final name in const [
              'x-user-id',
              'x-custom-uuid',
              'x-project-key',
            ])
              if (request.headers.value(name) != null)
                name: request.headers.value(name)!,
          },
          body: raw.isEmpty ? {} : jsonDecode(raw) as Map<String, dynamic>,
          path: request.uri.path,
        ),
      );

      request.response
        ..statusCode = 201
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'user': {'uuid': 'user-uuid-from-server'},
          }),
        );

      await request.response.close();
    });
  });

  tearDown(() async {
    IForeventsAPIIntegration.resetSingleton();
    await server.close(force: true);
  });

  IForeventsAPIIntegration build({
    int batchSize = 1,
    Future<Map<String, dynamic>> Function()? eventContext,
  }) {
    IForeventsAPIIntegration.resetSingleton();

    return IForeventsAPIIntegration(
      config: IForeventsAPIConfig(
        projectKey: 'pk_test',
        baseUrl: baseUrl,
        // batchSize 1 takes the single-event path, which is the one that used
        // to drop event_type.
        batchSize: batchSize,
        batchIntervalMs: 60000,
        enableRetry: false,
        eventContext: eventContext,
      ),
    );
  }

  final uuid4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test(
    'single track sends event_type so page views stay distinguishable',
    () async {
      final integration = build();
      await integration.init();

      await integration.pageView(
        event: const PageViewEvent(
          navigationType: 'didPush',
          toRoute: RouteSettings(name: '/home'),
          previousRoute: RouteSettings(name: '/splash'),
        ),
      );

      final track = captured.firstWhere(
        (r) => r.path.endsWith('/events/track'),
      );

      expect(track.body['event_name'], 'page_view');
      expect(track.body['event_type'], 'page_view');
    },
  );

  test('anonymous tracks carry a generated, persisted X-User-Id', () async {
    final integration = build();
    await integration.init();

    final anonymous = integration.userId;
    expect(anonymous, isNotNull);
    expect(anonymous, startsWith('anon_'));
    expect(integration.isIdentified, isFalse);

    await integration.track(event: const TrackEvent(eventName: 'app_open'));

    final track = captured.firstWhere((r) => r.path.endsWith('/events/track'));
    expect(track.headers['x-user-id'], anonymous);
    expect(track.headers.containsKey('x-custom-uuid'), isFalse);

    // The same id survives a restart: it is what keeps one device one user.
    expect(integration.getStoredUserId(), anonymous);
  });

  test('track carries the identified user in X-User-Id', () async {
    final integration = build();
    await integration.init();

    await integration.identify(
      event: const IdentifyEvent(customID: 'abc', properties: {}),
    );

    // The field, not just storage, has to pick the id up — otherwise
    // attribution only starts working after the next app launch.
    expect(integration.userId, 'abc');
    expect(integration.isIdentified, isTrue);

    await integration.track(event: const TrackEvent(eventName: 'checkout'));

    final identify = captured.firstWhere(
      (r) => r.path.endsWith('/events/identify'),
    );
    final track = captured.firstWhere((r) => r.path.endsWith('/events/track'));

    expect(identify.body['custom_id'], 'abc');
    expect(track.headers['x-user-id'], 'abc');
    expect(track.headers['x-project-key'], 'pk_test');
  });

  test('reset starts a new anonymous user', () async {
    final integration = build();
    await integration.init();

    await integration.identify(
      event: const IdentifyEvent(customID: 'abc', properties: {}),
    );
    await integration.reset();

    expect(integration.isIdentified, isFalse);
    expect(integration.userId, startsWith('anon_'));
    expect(integration.userId, isNot('abc'));

    await integration.track(event: const TrackEvent(eventName: 'after'));
    final track = captured.lastWhere((r) => r.path.endsWith('/events/track'));
    expect(track.headers['x-user-id'], integration.userId);
  });

  test('every call carries a unique message_id', () async {
    final integration = build();
    await integration.init();

    await integration.identify(
      event: const IdentifyEvent(customID: 'abc', properties: {}),
    );
    await integration.track(event: const TrackEvent(eventName: 'a'));
    await integration.track(event: const TrackEvent(eventName: 'b'));

    final ids = [for (final r in captured) r.body['message_id'] as String?];
    expect(ids, hasLength(3));
    for (final id in ids) {
      expect(id, matches(uuid4));
    }
    expect(ids.toSet(), hasLength(3));
  });

  test('anonymous_id is kept after identify and renewed on reset', () async {
    // Storage outlives a test: start as a device that never ran the SDK.
    await GetStorage().erase();
    final integration = build();
    await integration.init();
    final anon = integration.anonymousId;
    expect(anon, startsWith('anon_'));
    expect(integration.userId, anon);

    await integration.track(event: const TrackEvent(eventName: 'before'));
    await integration.identify(
      event: const IdentifyEvent(customID: 'abc', properties: {}),
    );
    await integration.track(event: const TrackEvent(eventName: 'after'));

    final tracks = captured
        .where((r) => r.path.endsWith('/events/track'))
        .toList();
    expect(tracks[0].headers['x-user-id'], anon);
    expect(tracks[0].body['anonymous_id'], anon);
    expect(tracks[1].headers['x-user-id'], 'abc');
    expect(tracks[1].body['anonymous_id'], anon);
    final identify = captured.firstWhere(
      (r) => r.path.endsWith('/events/identify'),
    );
    expect(identify.body['anonymous_id'], anon);

    await integration.reset();
    expect(integration.anonymousId, startsWith('anon_'));
    expect(integration.anonymousId, isNot(anon));
    expect(integration.userId, integration.anonymousId);
  });

  test('sent_at and context travel with every request', () async {
    final integration = build(
      eventContext: () async => {
        'library': {'name': 'iforevents', 'version': '9.9.9'},
        'locale': 'es-CO',
        'device': {'type': 'android'},
      },
    );
    await integration.init();
    final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));

    await integration.track(event: const TrackEvent(eventName: 'a'));

    final track = captured.firstWhere((r) => r.path.endsWith('/events/track'));
    expect(
      DateTime.parse(track.body['sent_at'] as String).isAfter(before),
      isTrue,
    );
    expect(track.body['context'], {
      'library': {'name': 'iforevents', 'version': '9.9.9'},
      'locale': 'es-CO',
      'device': {'type': 'android'},
    });
  });

  test('the default context names the library even without plugins', () async {
    final integration = build();
    await integration.init();

    await integration.track(event: const TrackEvent(eventName: 'a'));

    final track = captured.firstWhere((r) => r.path.endsWith('/events/track'));
    final context = track.body['context'] as Map<String, dynamic>;
    expect(context['library'], {
      'name': iforeventsLibraryName,
      'version': iforeventsLibraryVersion,
    });
  });

  test(
    'a batch carries the envelope once and a message_id per event',
    () async {
      final integration = build(batchSize: 2);
      await integration.init();

      await integration.track(event: const TrackEvent(eventName: 'a'));
      await integration.track(event: const TrackEvent(eventName: 'b'));

      final batch = captured.firstWhere(
        (r) => r.path.endsWith('/events/batch'),
      );
      expect(batch.body['anonymous_id'], integration.anonymousId);
      expect(batch.body['sent_at'], isA<String>());
      expect(batch.body['context'], isA<Map<String, dynamic>>());
      final events = (batch.body['events'] as List)
          .cast<Map<String, dynamic>>();
      expect(events, hasLength(2));
      expect(events[0]['message_id'], matches(uuid4));
      expect(events[0]['message_id'], isNot(events[1]['message_id']));
    },
  );

  test(
    'a failing context provider sends {} and the event still goes',
    () async {
      final integration = build(
        eventContext: () async => throw StateError('no device info'),
      );
      await integration.init();

      await integration.track(event: const TrackEvent(eventName: 'a'));

      final track = captured.firstWhere(
        (r) => r.path.endsWith('/events/track'),
      );
      expect(track.body['event_name'], 'a');
      expect(track.body['context'], <String, dynamic>{});
    },
  );
}
