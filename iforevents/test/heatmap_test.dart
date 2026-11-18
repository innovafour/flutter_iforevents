// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/iforevents.dart';

void main() {
  late List<Map<String, dynamic>> sent;
  Future<void> capture(Map<String, dynamic> p) async => sent.add(p);

  setUp(() => sent = []);

  Widget app() => MaterialApp(
    home: IforeventsHeatmap(
      send: capture,
      flushInterval: const Duration(hours: 1),
      child: Scaffold(
        body: ListView(
          children: [
            ElevatedButton(
              key: const ValueKey('buy'),
              onPressed: () {},
              child: const Text('Buy now'),
            ),
            const SizedBox(height: 40),
            const Text('Plain text', key: ValueKey('plain')),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    ),
  );

  testWidgets('records taps with the widget tapped, dead and rage taps', (
    tester,
  ) async {
    IforeventsHeatmap.currentScreen = 'CheckoutScreen';
    await tester.pumpWidget(app());
    await tester.tap(find.byKey(const ValueKey('buy')));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('plain')));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 1));

    await IforeventsHeatmap.flush();
    expect(sent, hasLength(1));
    final p = sent.single;
    expect(p['page'], 'CheckoutScreen');
    expect(p['page_view_id'], hasLength(24));
    final items = (p['items'] as List).cast<Map<String, dynamic>>();
    final clicks = items.where((i) => i['k'] == 'click').toList();
    expect(clicks, hasLength(4));
    expect(clicks.first['tag'], 'ElevatedButton');
    expect(clicks.first['txt'], 'Buy now');
    expect(clicks.first['s'], contains('ElevatedButton[key=buy]'));
    expect(items.where((i) => i['k'] == 'dead_click'), hasLength(3));
    expect(items.where((i) => i['k'] == 'rage_click'), hasLength(1));
    expect(items.where((i) => i['k'] == 'scroll'), hasLength(1));
    expect(items.where((i) => i['k'] == 'attention'), isNotEmpty);
    expect((p['viewport'] as Map)['w'], greaterThan(0));
    expect(
      (p['document'] as Map)['h'],
      greaterThan((p['viewport'] as Map)['h']),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('scrolling deepens the scroll summary and offsets taps', (
    tester,
  ) async {
    IforeventsHeatmap.currentScreen = 'ListScreen';
    await tester.pumpWidget(app());
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await IforeventsHeatmap.flush();
    final items = (sent.last['items'] as List).cast<Map<String, dynamic>>();
    final scroll = items.firstWhere((i) => i['k'] == 'scroll');
    final viewport = (sent.last['viewport'] as Map)['h'] as int;
    expect(scroll['y'] as int, greaterThan(viewport + 400));
    await tester.pumpWidget(const SizedBox());
  });

  test(
    'a screen change starts a new screen view and sampling can skip it',
    () async {
      final out = <Map<String, dynamic>>[];
      final r = HeatmapRecorder(send: (p) async => out.add(p));
      r.start('/a');
      r.size = const Size(400, 800);
      r.tap(
        const Offset(200, 100),
        const Size(400, 800),
        const HeatmapTarget(
          selector: 'X',
          tag: 'X',
          text: '',
          interactive: true,
        ),
      );
      final first = r.screenViewId;
      r.newScreen('/b');
      expect(r.screenViewId, isNot(first));
      expect(out, hasLength(1));
      expect(out.single['page'], '/a');
      final items = (out.single['items'] as List).cast<Map<String, dynamic>>();
      expect(items.first['x'], 5000);
      r.stop();

      final skipped = <Map<String, dynamic>>[];
      final none = HeatmapRecorder(
        send: (p) async => skipped.add(p),
        sampleRate: 0,
      );
      none.start('/a');
      none.tap(
        Offset.zero,
        const Size(400, 800),
        const HeatmapTarget(
          selector: '',
          tag: '',
          text: '',
          interactive: false,
        ),
      );
      none.stop();
      expect(skipped, isEmpty);
    },
  );
}
