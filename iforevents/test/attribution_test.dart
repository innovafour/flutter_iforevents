import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/utils/attribution.dart';

void main() {
  group('attribution', () {
    test('reads utm parameters and click ids of a deep link', () {
      expect(
        attributionFromUri(
          Uri.parse(
            'myapp://promo?utm_source=tiktok&utm_campaign=launch&ttclid=t1&x=1',
          ),
        ),
        {'utm_source': 'tiktok', 'utm_campaign': 'launch', 'ttclid': 't1'},
      );
      expect(attributionFromUri(Uri.parse('myapp://home')), isEmpty);
    });

    test('adds an external referring domain only', () {
      expect(
        attributionFromUri(
          Uri.parse('https://shop.example/p'),
          referrer: Uri.parse('https://www.google.com/'),
        ),
        {'referring_domain': 'google.com'},
      );
      expect(
        attributionFromUri(
          Uri.parse('https://www.shop.example/p'),
          referrer: Uri.parse('https://shop.example/'),
        ),
        isEmpty,
      );
    });

    test('reads an install referrer', () {
      expect(
        attributionFromQuery('utm_source=google-play&utm_medium=organic'),
        {'utm_source': 'google-play', 'utm_medium': 'organic'},
      );
    });

    test('keeps the session attribution for 30 minutes of inactivity', () {
      var now = DateTime(2026, 11, 18, 10);
      final tracker = AttributionTracker(clock: () => now);
      expect(tracker.apply({'a': 1}, {'utm_source': 'x'}), {
        'utm_source': 'x',
        'a': 1,
      });
      now = now.add(const Duration(minutes: 29));
      expect(tracker.apply({'utm_source': 'mine'}), {'utm_source': 'mine'});
      now = now.add(const Duration(minutes: 29));
      expect(tracker.apply({}), {'utm_source': 'x'});
      now = now.add(const Duration(minutes: 31));
      expect(tracker.apply({}), isEmpty);
    });
  });
}
