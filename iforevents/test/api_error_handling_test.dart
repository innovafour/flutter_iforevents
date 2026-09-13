import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

/// A scripted server: each request consumes the next (status, body,
/// headers) answer; the last answer repeats.
class _Answer {
  const _Answer(this.status, this.body, {this.headers = const {}});

  final int status;
  final Map<String, dynamic> body;
  final Map<String, String> headers;
}

void main() {
  late HttpServer server;
  late List<_Answer> script;
  late int requests;
  late String baseUrl;
  late Directory storageDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    storageDir = await Directory.systemTemp.createTemp('iforevents_errors');
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
    script = [];
    requests = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    baseUrl = 'http://${server.address.host}:${server.port}';
    server.listen((request) async {
      await utf8.decoder.bind(request).join();
      final answer =
          script[requests < script.length ? requests : script.length - 1];
      requests += 1;
      request.response.statusCode = answer.status;
      request.response.headers.contentType = ContentType.json;
      answer.headers.forEach(request.response.headers.set);
      request.response.write(jsonEncode(answer.body));
      await request.response.close();
    });
  });

  tearDown(() async {
    IForeventsAPIIntegration.resetSingleton();
    await server.close(force: true);
  });

  IForeventsAPIIntegration build({
    int batchSize = 1,
    bool enableRetry = false,
    bool throwOnError = true,
    void Function(IForeventsQuotaExceededException)? onQuotaExceeded,
  }) {
    IForeventsAPIIntegration.resetSingleton();
    return IForeventsAPIIntegration(
      config: IForeventsAPIConfig(
        projectKey: 'pk_test',
        baseUrl: baseUrl,
        batchSize: batchSize,
        enableRetry: enableRetry,
        maxRetries: 2,
        retryDelayMs: 10,
        throwOnError: throwOnError,
        onQuotaExceeded: onQuotaExceeded,
      ),
    );
  }

  const quota = _Answer(429, {
    'error': 'quota_exceeded',
    'message': 'monthly event quota exceeded: 5000001/5000000',
    'org_uuid': 'org-1',
    'limit': 5000000,
    'used': 5000001,
  });
  const ok = _Answer(201, {'status': 'ok', 'user_uuid': 'u-1'});

  test(
    'quota_exceeded surfaces as a typed exception with the numbers',
    () async {
      script = [quota];
      IForeventsQuotaExceededException? reported;
      final integration = build(onQuotaExceeded: (e) => reported = e);
      await integration.init();

      await expectLater(
        integration.track(event: const TrackEvent(eventName: 'x')),
        throwsA(
          isA<IForeventsQuotaExceededException>()
              .having((e) => e.limit, 'limit', 5000000)
              .having((e) => e.used, 'used', 5000001)
              .having((e) => e.organizationUuid, 'org', 'org-1')
              .having((e) => e.code, 'code', 'quota_exceeded'),
        ),
      );
      expect(integration.isQuotaExceeded, isTrue);
      expect(reported, isNotNull);
    },
  );

  test('quota_exceeded drops the batch instead of re-queueing it', () async {
    script = [quota, ok];
    var callbacks = 0;
    final integration = build(
      batchSize: 2,
      throwOnError: false,
      onQuotaExceeded: (_) => callbacks++,
    );
    await integration.init();

    await integration.track(event: const TrackEvent(eventName: 'a'));
    await integration.track(event: const TrackEvent(eventName: 'b'));

    expect(requests, 1, reason: 'the batch was sent once');
    expect(
      integration.queuedEventsCount,
      0,
      reason: 'refused events are not re-queued',
    );
    expect(integration.isQuotaExceeded, isTrue);
    expect(callbacks, 1);

    // A later accepted batch clears the flag.
    await integration.track(event: const TrackEvent(eventName: 'c'));
    await integration.track(event: const TrackEvent(eventName: 'd'));
    expect(requests, 2);
    expect(integration.isQuotaExceeded, isFalse);
  });

  test('a refused key is an auth exception and is not retried', () async {
    script = [
      const _Answer(401, {'error': 'invalid project key'}),
    ];
    final integration = build(enableRetry: true);
    await integration.init();

    await expectLater(
      integration.track(event: const TrackEvent(eventName: 'x')),
      throwsA(
        isA<IForeventsAuthException>().having(
          (e) => e.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(requests, 1);
  });

  test(
    'a plain rate limit retries after Retry-After and then succeeds',
    () async {
      script = [
        const _Answer(
          429,
          {'error': 'rate limit exceeded'},
          headers: {'retry-after': '1'},
        ),
        ok,
      ];
      final integration = build(enableRetry: true);
      await integration.init();

      final started = DateTime.now();
      await integration.track(event: const TrackEvent(eventName: 'x'));
      expect(requests, 2);
      expect(
        DateTime.now().difference(started).inMilliseconds,
        greaterThanOrEqualTo(900),
      );
    },
  );

  test('transient failures still re-queue the batch', () async {
    script = [
      const _Answer(503, {'error': 'not ready'}),
    ];
    final integration = build(batchSize: 2, throwOnError: false);
    await integration.init();

    await integration.track(event: const TrackEvent(eventName: 'a'));
    await integration.track(event: const TrackEvent(eventName: 'b'));
    expect(integration.queuedEventsCount, 2);
  });
}
