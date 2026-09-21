import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/config/retry_config.dart';

void main() {
  setUp(RetryConfig.resetToDefaults);

  group('RetryConfig intervals', () {
    test('defaults to the balanced backoff', () {
      expect(RetryConfig.retryIntervals, [30, 120, 300]);
      expect(RetryConfig.backgroundProcessingInterval, 30);
    });

    test('the getter returns a copy, so callers cannot mutate state', () {
      RetryConfig.retryIntervals[0] = 9999;
      expect(RetryConfig.retryIntervals[0], 30);
    });

    test('accepts a valid custom backoff', () {
      expect(RetryConfig.setRetryIntervals([15, 60, 180]), isTrue);
      expect(RetryConfig.retryIntervals, [15, 60, 180]);
    });

    test('rejects the wrong number of intervals', () {
      expect(RetryConfig.setRetryIntervals([30, 120]), isFalse);
      expect(RetryConfig.setRetryIntervals([30, 120, 300, 600]), isFalse);
      expect(RetryConfig.retryIntervals, [30, 120, 300]);
    });

    test('rejects intervals outside the allowed range', () {
      expect(
        RetryConfig.setRetryIntervals([
          RetryConfig.minimumRetryInterval - 1,
          60,
          180,
        ]),
        isFalse,
      );
      expect(
        RetryConfig.setRetryIntervals([
          30,
          60,
          RetryConfig.maximumRetryInterval + 1,
        ]),
        isFalse,
      );
    });

    test('accepts exactly the range boundaries', () {
      expect(
        RetryConfig.setRetryIntervals([
          RetryConfig.minimumRetryInterval,
          600,
          RetryConfig.maximumRetryInterval,
        ]),
        isTrue,
      );
    });
  });

  group('RetryConfig.getRetryIntervalForAttempt', () {
    test('maps attempts 1..3 onto the configured intervals', () {
      expect(RetryConfig.getRetryIntervalForAttempt(1), 30);
      expect(RetryConfig.getRetryIntervalForAttempt(2), 120);
      expect(RetryConfig.getRetryIntervalForAttempt(3), 300);
    });

    // Off-by-one here would either retry instantly or index out of range.
    test('returns null outside the valid attempt range', () {
      expect(RetryConfig.getRetryIntervalForAttempt(0), isNull);
      expect(RetryConfig.getRetryIntervalForAttempt(-1), isNull);
      expect(
        RetryConfig.getRetryIntervalForAttempt(
          RetryConfig.maxRetryAttempts + 1,
        ),
        isNull,
      );
    });
  });

  group('RetryConfig background interval', () {
    test('accepts a value inside the range', () {
      expect(RetryConfig.setBackgroundProcessingInterval(45), isTrue);
      expect(RetryConfig.backgroundProcessingInterval, 45);
    });

    test('rejects values outside the range', () {
      expect(RetryConfig.setBackgroundProcessingInterval(1), isFalse);
      expect(RetryConfig.setBackgroundProcessingInterval(99999), isFalse);
      expect(RetryConfig.backgroundProcessingInterval, 30);
    });
  });

  group('RetryConfig serialization', () {
    test('round trips through a map', () {
      RetryConfig.setRetryIntervals([20, 90, 240]);
      RetryConfig.setBackgroundProcessingInterval(60);

      final serialized = RetryConfig.toMap();
      RetryConfig.resetToDefaults();

      expect(RetryConfig.fromMap(serialized), isTrue);
      expect(RetryConfig.retryIntervals, [20, 90, 240]);
      expect(RetryConfig.backgroundProcessingInterval, 60);
    });

    test('refuses an invalid map and keeps the previous config', () {
      expect(
        RetryConfig.fromMap({
          'retryIntervals': [1, 2],
        }),
        isFalse,
      );
      expect(RetryConfig.retryIntervals, [30, 120, 300]);
    });
  });

  group('RetryConfig presets', () {
    test('every preset is itself valid', () {
      for (final name in RetryConfig.availablePresets) {
        expect(
          RetryConfig.applyPresetConfiguration(name),
          isTrue,
          reason: 'preset "$name" is not a valid configuration',
        );
      }
    });

    test('aggressive is faster than patient at every step', () {
      final aggressive = RetryConfig.presetConfigurations['aggressive']!;
      final patient = RetryConfig.presetConfigurations['patient']!;

      for (var i = 0; i < aggressive.length; i++) {
        expect(aggressive[i], lessThan(patient[i]));
      }
    });

    test('an unknown preset is refused', () {
      expect(RetryConfig.applyPresetConfiguration('nope'), isFalse);
    });
  });
}
