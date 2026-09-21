import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

void main() {
  group('IForeventsAPIConfig', () {
    test('only requires the public project key', () {
      const config = IForeventsAPIConfig(projectKey: 'pk_live_abc');

      expect(config.projectKey, 'pk_live_abc');
      expect(config.baseUrl, 'https://api.iforevents.com');
    });

    // The third-party IP lookup discloses the user's address, so it must never
    // be on unless the integrator asked for it.
    test('public IP collection is off unless enabled', () {
      const config = IForeventsAPIConfig(projectKey: 'pk');
      expect(config.collectPublicIP, isFalse);

      const opted = IForeventsAPIConfig(
        projectKey: 'pk',
        collectPublicIP: true,
      );
      expect(opted.collectPublicIP, isTrue);
    });

    test('copyWith replaces only what it is given', () {
      const config = IForeventsAPIConfig(
        projectKey: 'pk',
        batchSize: 25,
        enableLogging: true,
      );

      final updated = config.copyWith(projectKey: 'pk2');

      expect(updated.projectKey, 'pk2');
      expect(updated.batchSize, 25);
      expect(updated.enableLogging, isTrue);
    });

    test('copyWith can toggle every flag', () {
      const config = IForeventsAPIConfig(projectKey: 'pk');

      final updated = config.copyWith(
        baseUrl: 'https://self.hosted',
        batchSize: 1,
        batchIntervalMs: 100,
        connectTimeoutMs: 1,
        receiveTimeoutMs: 2,
        sendTimeoutMs: 3,
        enableRetry: false,
        maxRetries: 9,
        retryDelayMs: 50,
        enableLogging: true,
        throwOnError: true,
        requeueFailedEvents: false,
        collectPublicIP: true,
      );

      expect(updated.baseUrl, 'https://self.hosted');
      expect(updated.batchSize, 1);
      expect(updated.batchIntervalMs, 100);
      expect(updated.connectTimeoutMs, 1);
      expect(updated.receiveTimeoutMs, 2);
      expect(updated.sendTimeoutMs, 3);
      expect(updated.enableRetry, isFalse);
      expect(updated.maxRetries, 9);
      expect(updated.retryDelayMs, 50);
      expect(updated.enableLogging, isTrue);
      expect(updated.throwOnError, isTrue);
      expect(updated.requeueFailedEvents, isFalse);
      expect(updated.collectPublicIP, isTrue);
    });
  });
}
