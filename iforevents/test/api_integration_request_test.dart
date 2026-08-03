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
/// These two details are worth a real socket rather than a mock: both were
/// wrong at once, and both are invisible to a unit test that stops at the
/// integration's public surface. The API reads the user id from
/// `X-Custom-UUID` and rejects nothing when it is missing — it just files the
/// event as anonymous — so a wrong header name fails silently in production.
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
            for (final name in const ['x-custom-uuid', 'x-project-key'])
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

  IForeventsAPIIntegration build() {
    IForeventsAPIIntegration.resetSingleton();

    return IForeventsAPIIntegration(
      config: IForeventsAPIConfig(
        projectKey: 'pk_test',
        baseUrl: baseUrl,
        // batchSize 1 takes the single-event path, which is the one that used
        // to drop event_type.
        batchSize: 1,
        enableRetry: false,
      ),
    );
  }

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

  test('track carries the identified user in X-Custom-UUID', () async {
    final integration = build();
    await integration.init();

    await integration.identify(
      event: const IdentifyEvent(customID: 'abc', properties: {}),
    );

    // The field, not just storage, has to pick the uuid up — otherwise
    // attribution only starts working after the next app launch.
    expect(integration.userUUID, 'user-uuid-from-server');

    await integration.track(event: const TrackEvent(eventName: 'checkout'));

    final track = captured.firstWhere((r) => r.path.endsWith('/events/track'));

    expect(track.headers['x-custom-uuid'], 'user-uuid-from-server');
    expect(track.headers['x-project-key'], 'pk_test');
  });
}
