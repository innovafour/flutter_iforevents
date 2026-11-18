import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:iforevents/integration/iforevents.dart';

/// Records heatmaps of the app: taps with the widget tapped, rage taps (a
/// burst on one spot), dead taps (a tap on something that is not
/// interactive), how far down each screen was scrolled, the time on screen
/// and how long each 5% band of a scrolling screen was visible. Sent,
/// aggregated, to `POST /v1/events/heatmap` through
/// [IForeventsAPIIntegration], and shown in the dashboard under Heatmaps.
///
/// Wrap the app once, above the navigator, and add
/// [IforeventsRouteObserver] so every route is its own screen:
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [IforeventsRouteObserver(iforevents: iforevents)],
///   builder: (context, child) => IforeventsHeatmap(child: child!),
/// );
/// ```
///
/// Positions are relative to the screen's content: x in hundredths of a
/// percent of the width, y in logical pixels from the top of the scrolled
/// content. Never recorded: what is typed or the value of any field. Text
/// of the tapped widget is sent unless [maskText] is true.
class IforeventsHeatmap extends StatefulWidget {
  const IforeventsHeatmap({
    super.key,
    required this.child,
    this.enabled = true,
    this.sampleRate = 1.0,
    this.maskText = false,
    this.flushInterval = const Duration(seconds: 15),
    this.send,
  });

  final Widget child;

  /// Where batches go; by default [IForeventsAPIIntegration.sendHeatmap].
  final Future<void> Function(Map<String, dynamic> payload)? send;

  /// Turns recording off without removing the widget.
  final bool enabled;

  /// Share of screen views recorded, 0 to 1.
  final double sampleRate;

  /// Never send the text of the tapped widget.
  final bool maskText;

  /// How often what was recorded is sent while the screen is open.
  final Duration flushInterval;

  /// The screen heatmaps are grouped by: the current route's name, set by
  /// [IforeventsRouteObserver]. Set it yourself for apps without named
  /// routes.
  static String get currentScreen => _screen;
  static set currentScreen(String name) {
    final next = name.trim().isEmpty ? '/' : name.trim();
    if (next == _screen) return;
    _screen = next;
    for (final s in List.of(_states)) {
      s._recorder.newScreen(next);
    }
  }

  /// Sends what every recorder holds now (before a known exit, or in tests).
  static Future<void> flush() async {
    for (final s in List.of(_states)) {
      await s._recorder.flush();
    }
  }

  static String _screen = '/';
  static final Set<_IforeventsHeatmapState> _states = {};

  @override
  State<IforeventsHeatmap> createState() => _IforeventsHeatmapState();
}

class _IforeventsHeatmapState extends State<IforeventsHeatmap>
    with WidgetsBindingObserver {
  late final HeatmapRecorder _recorder;
  final GlobalKey _boundary = GlobalKey();
  final Map<int, _Pointer> _pointers = {};

  @override
  void initState() {
    super.initState();
    _recorder = HeatmapRecorder(
      send:
          widget.send ??
          (payload) async =>
              IForeventsAPIIntegration.instance?.sendHeatmap(payload),
      sampleRate: widget.sampleRate,
      flushInterval: widget.flushInterval,
      platform: _platform(),
    );
    if (widget.enabled) _recorder.start(IforeventsHeatmap.currentScreen);
    IforeventsHeatmap._states.add(this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    IforeventsHeatmap._states.remove(this);
    WidgetsBinding.instance.removeObserver(this);
    _recorder.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _recorder.flush();
      _recorder.visible = false;
    } else if (state == AppLifecycleState.resumed) {
      _recorder.visible = true;
    }
  }

  static String _platform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  Size get _size {
    final box = _boundary.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return box.size;
    final view = View.maybeOf(context);
    if (view != null) return view.physicalSize / view.devicePixelRatio;
    return Size.zero;
  }

  void _onDown(PointerDownEvent e) {
    if (!widget.enabled) return;
    // Described now: once a gesture is under way a scroll view can ignore
    // pointers, and a hit test at pointer up would stop at it.
    _pointers[e.pointer] = _Pointer(
      e.position,
      e.localPosition,
      e.timeStamp,
      describeTarget(e.position, maskText: widget.maskText),
    );
  }

  void _onUp(PointerUpEvent e) {
    final down = _pointers.remove(e.pointer);
    if (down == null || !widget.enabled) return;
    final moved = (e.position - down.global).distance;
    final held = e.timeStamp - down.at;
    if (moved > 18 || held > const Duration(milliseconds: 600)) return;
    _recorder.tap(down.local, _size, down.target);
  }

  void _onCancel(PointerCancelEvent e) => _pointers.remove(e.pointer);

  bool _onScroll(ScrollNotification n) {
    if (widget.enabled && n.metrics.axis == Axis.vertical) {
      _recorder.scrolled(n.metrics, _size);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Listener(
        key: _boundary,
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onDown,
        onPointerUp: _onUp,
        onPointerCancel: _onCancel,
        child: widget.child,
      ),
    );
  }
}

class _Pointer {
  _Pointer(this.global, this.local, this.at, this.target);
  final Offset global;
  final Offset local;
  final Duration at;
  final HeatmapTarget target;
}

/// What a tap landed on: a short path of widget types, the interactive
/// widget's own type, its text, and whether anything on the path reacts to
/// taps.
class HeatmapTarget {
  const HeatmapTarget({
    required this.selector,
    required this.tag,
    required this.text,
    required this.interactive,
  });

  final String selector;
  final String tag;
  final String text;
  final bool interactive;
}

// Widgets people tap, named as people would: a button, a tile, a switch.
const _highNames = [
  'Button',
  'ListTile',
  'Checkbox',
  'Switch',
  'Radio',
  'Slider',
  'Chip',
  'TextField',
  'TextFormField',
  'Tab',
  'PopupMenu',
  'Dropdown',
  'MenuItem',
  'Stepper',
  'ExpansionTile',
  'NavigationDestination',
  'BottomNavigationBar',
  'SegmentedButton',
];

// What those are built from, and what apps use directly for custom taps.
const _lowNames = [
  'InkWell',
  'InkResponse',
  'GestureDetector',
  'EditableText',
  'Dismissible',
  'Draggable',
];

// Widgets worth naming in a path: the ones people would recognise. Framework
// plumbing (Padding, Semantics, _InkFeatures, ...) is skipped.
const _landmarkNames = [
  'Scaffold',
  'AppBar',
  'ListView',
  'GridView',
  'CustomScrollView',
  'SingleChildScrollView',
  'Card',
  'Dialog',
  'BottomSheet',
  'Drawer',
  'Form',
  'TabBar',
  'NavigationBar',
  'BottomNavigationBar',
];

bool _isHigh(String name) =>
    !name.startsWith('_') && _highNames.any((n) => name.contains(n));
bool _isLow(String name) => _lowNames.any((n) => name.contains(n));
bool _isLandmark(String name) => _landmarkNames.contains(name);

/// Finds the widget under [globalPosition] by hit-testing the render tree
/// and walking only the elements on the hit path. Runs once per tap.
HeatmapTarget describeTarget(Offset globalPosition, {bool maskText = false}) {
  try {
    final binding = WidgetsBinding.instance;
    final result = HitTestResult();
    final views = binding.renderViews;
    if (views.isEmpty) {
      return const HeatmapTarget(
        selector: '',
        tag: '',
        text: '',
        interactive: false,
      );
    }
    binding.hitTestInView(
      result,
      globalPosition,
      views.first.flutterView.viewId,
    );
    // Some render objects forward a hit to their child without entering
    // the result (translations, for one): the path is every hit render
    // object and all of its ancestors.
    final hit = <RenderObject>{};
    for (final entry in result.path) {
      RenderObject? ro = entry.target is RenderObject
          ? entry.target as RenderObject
          : null;
      while (ro != null && hit.add(ro)) {
        ro = ro.parent;
      }
    }
    final chain = <Element>[];
    void visit(Element el) {
      final ro = el.renderObject;
      if (ro == null || !hit.contains(ro)) return;
      chain.add(el);
      el.visitChildElements(visit);
    }

    binding.rootElement?.visitChildElements(visit);

    // The deepest widget that reacts to taps, then the nearest widget above
    // it that people would name (the ElevatedButton around its InkWell and
    // RawGestureDetector); a plain GestureDetector or InkWell otherwise.
    Element? interactive;
    var deepest = -1;
    for (var i = chain.length - 1; i >= 0; i--) {
      final name = chain[i].widget.runtimeType.toString();
      // A scroll view's own drag detector is not something people tap.
      if (name == 'Scrollable' ||
          name.endsWith('Viewport') ||
          _isLandmark(name)) {
        break;
      }
      if (_isHigh(name) || _isLow(name)) {
        deepest = i;
        break;
      }
    }
    if (deepest >= 0) {
      for (var i = deepest; i >= 0 && i >= deepest - 60; i--) {
        if (_isHigh(chain[i].widget.runtimeType.toString())) {
          interactive = chain[i];
          break;
        }
      }
      if (interactive == null) {
        for (var i = deepest; i >= 0 && i >= deepest - 10; i--) {
          final name = chain[i].widget.runtimeType.toString();
          if (_isLow(name) &&
              !name.startsWith('Raw') &&
              !name.startsWith('_')) {
            interactive = chain[i];
            break;
          }
        }
      }
      interactive ??= chain[deepest];
    }
    final target = interactive ?? (chain.isNotEmpty ? chain.last : null);
    if (target == null) {
      return const HeatmapTarget(
        selector: '',
        tag: '',
        text: '',
        interactive: false,
      );
    }
    final parts = <String>[];
    for (final el in chain) {
      if (identical(el, target)) break;
      final name = el.widget.runtimeType.toString();
      if (_isLandmark(name)) parts.add(name);
    }
    final tag = target.widget.runtimeType.toString();
    final key = target.widget.key;
    var self = tag;
    if (key is ValueKey<String>) self += '[key=${key.value}]';
    final selector = [
      ...parts.skip(math.max(0, parts.length - 3)),
      self,
    ].join(' > ');
    var text = '';
    if (!maskText &&
        !tag.contains('TextField') &&
        !tag.contains('EditableText')) {
      text = _firstText(target);
    }
    return HeatmapTarget(
      selector: selector,
      tag: tag,
      text: text,
      interactive: interactive != null,
    );
  } catch (_) {
    return const HeatmapTarget(
      selector: '',
      tag: '',
      text: '',
      interactive: false,
    );
  }
}

String _firstText(Element root) {
  String found = '';
  var visited = 0;
  void visit(Element el) {
    if (found.isNotEmpty || visited++ > 200) return;
    final w = el.widget;
    if (w is Text) {
      found = w.data ?? w.textSpan?.toPlainText() ?? '';
    } else if (w is RichText) {
      found = w.text.toPlainText();
    } else if (w is Semantics && (w.properties.label?.isNotEmpty ?? false)) {
      found = w.properties.label!;
    }
    if (found.isEmpty) el.visitChildElements(visit);
  }

  visit(root);
  found = found.replaceAll(RegExp(r'\s+'), ' ').trim();
  return found.length > 80 ? found.substring(0, 80) : found;
}

/// The recording state of one screen view, independent of widgets so it
/// can be tested.
class HeatmapRecorder {
  HeatmapRecorder({
    required this.send,
    this.sampleRate = 1.0,
    this.flushInterval = const Duration(seconds: 15),
    this.platform = 'app',
    math.Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? math.Random(),
       _clock = clock ?? DateTime.now;

  final Future<void> Function(Map<String, dynamic> payload) send;
  final double sampleRate;
  final Duration flushInterval;
  final String platform;
  final math.Random _random;
  final DateTime Function() _clock;

  static const int bands = 20;
  static const int maxItems = 1500;
  static const int rageTaps = 3;
  static const Duration rageWindow = Duration(milliseconds: 800);
  static const double rageRadius = 30;
  static const Duration tick = Duration(milliseconds: 500);

  bool visible = true;
  bool _running = false;
  bool _sampled = false;
  String _screen = '/';
  String _id = '';
  DateTime _startedAt = DateTime.now();
  final List<Map<String, dynamic>> _items = [];
  List<int> _attention = List.filled(bands, 0);
  final List<({DateTime at, Offset p})> _recent = [];
  DateTime _rageUntil = DateTime.fromMillisecondsSinceEpoch(0);
  int _visibleMs = 0;
  double _maxBottom = 0;
  double _scrollPixels = 0;
  double _contentHeight = 0;
  Size _size = Size.zero;
  bool _dirty = false;
  Timer? _flushTimer;
  Timer? _tickTimer;
  DateTime _lastTick = DateTime.now();

  /// The current screen view's id.
  String get screenViewId => _id;
  String get screen => _screen;
  bool get sampled => _sampled;

  void start(String screen) {
    if (_running) return;
    _running = true;
    _open(screen);
    _flushTimer = Timer.periodic(flushInterval, (_) => flush());
    _tickTimer = Timer.periodic(tick, (_) => onTick());
  }

  void stop() {
    flush();
    _running = false;
    _flushTimer?.cancel();
    _tickTimer?.cancel();
  }

  /// Ends the current screen view (sending what is left) and starts one
  /// for [screen].
  void newScreen(String screen) {
    if (!_running) return;
    flush();
    _open(screen);
  }

  void _open(String screen) {
    _screen = screen;
    _sampled = _random.nextDouble() < sampleRate.clamp(0.0, 1.0);
    _id = List.generate(
      24,
      (_) => _random.nextInt(16).toRadixString(16),
    ).join();
    _startedAt = _clock();
    _lastTick = _startedAt;
    _items.clear();
    _attention = List.filled(bands, 0);
    _recent.clear();
    _visibleMs = 0;
    _maxBottom = 0;
    _scrollPixels = 0;
    _contentHeight = 0;
    _dirty = true;
  }

  double get _docHeight => math.max(_contentHeight, _size.height).toDouble();

  int _x(double dx) =>
      _size.width <= 0 ? 0 : (dx / _size.width * 10000).round().clamp(0, 10000);

  void _push(Map<String, dynamic> item) {
    if (!_sampled || _items.length >= maxItems) return;
    item['t'] = _clock().difference(_startedAt).inMilliseconds;
    _items.add(item);
    _dirty = true;
  }

  /// A tap at [local] (relative to the recorded area of [size]).
  void tap(Offset local, Size size, HeatmapTarget target) {
    if (!_running || !_sampled) return;
    _size = size;
    final x = _x(local.dx);
    final y = (local.dy + _scrollPixels).round().clamp(0, 200000);
    final desc = <String, dynamic>{
      if (target.selector.isNotEmpty) 's': target.selector,
      if (target.tag.isNotEmpty) 'tag': target.tag,
      if (target.text.isNotEmpty) 'txt': target.text,
    };
    _push({'k': 'click', 'x': x, 'y': y, ...desc});
    final now = _clock();
    _recent.removeWhere((r) => now.difference(r.at) > rageWindow);
    _recent.add((at: now, p: local));
    final near = _recent
        .where((r) => (r.p - local).distance <= rageRadius)
        .length;
    if (near >= rageTaps && now.isAfter(_rageUntil)) {
      _push({'k': 'rage_click', 'x': x, 'y': y, 'v': near, ...desc});
      _rageUntil = now.add(rageWindow);
    }
    // A tap on nothing that reacts to taps is a dead tap.
    if (!target.interactive) {
      _push({'k': 'dead_click', 'x': x, 'y': y, ...desc});
    }
  }

  /// The screen's main vertical scrollable moved.
  void scrolled(ScrollMetrics m, Size size) {
    if (!_running) return;
    _size = size;
    // The largest scrollable is the screen's content; nested lists are not.
    final content = m.maxScrollExtent + m.viewportDimension;
    if (content + 1 < _contentHeight &&
        m.viewportDimension < size.height * 0.6) {
      return;
    }
    _scrollPixels = m.pixels.clamp(0.0, m.maxScrollExtent).toDouble();
    _contentHeight = content - m.viewportDimension + size.height;
    final bottom = _scrollPixels + size.height;
    if (bottom > _maxBottom) {
      _maxBottom = bottom;
      _dirty = true;
    }
  }

  /// Every [tick] while the app is visible: time on screen, and time on
  /// screen for every 5% band at least half visible.
  void onTick() {
    final now = _clock();
    final elapsed = math.min(now.difference(_lastTick).inMilliseconds, 2500);
    _lastTick = now;
    if (!_running || !_sampled || !visible || _size.height <= 0) return;
    _visibleMs += elapsed;
    if (_maxBottom < _size.height) _maxBottom = _size.height;
    final h = _docHeight;
    final top = _scrollPixels;
    final bottom = top + _size.height;
    final band = h / bands;
    for (var i = 0; i < bands; i++) {
      final from = i * band;
      final to = from + band;
      final seen = math.min(to, bottom) - math.max(from, top);
      if (seen >= band / 2) _attention[i] += elapsed;
    }
    _dirty = true;
  }

  /// Updates the recorded area without a tap or scroll (first layout).
  set size(Size s) => _size = s;

  /// The payload of what was recorded since the last send, or null.
  Map<String, dynamic>? takePayload() {
    if (!_sampled || !_dirty) return null;
    final items = List<Map<String, dynamic>>.of(_items);
    _items.clear();
    for (var i = 0; i < bands; i++) {
      if (_attention[i] > 0) {
        items.add({'k': 'attention', 'x': 0, 'y': i, 'v': _attention[i]});
      }
    }
    _attention = List.filled(bands, 0);
    items.add({
      'k': 'scroll',
      'x': 0,
      'y': math.max(_maxBottom, _size.height).round(),
      'v': _visibleMs,
    });
    _dirty = false;
    return {
      'page_view_id': _id,
      'page': _screen,
      'platform': platform,
      'viewport': {'w': _size.width.round(), 'h': _size.height.round()},
      'document': {'w': _size.width.round(), 'h': _docHeight.round()},
      'created_at': _startedAt.toUtc().toIso8601String(),
      'items': items,
    };
  }

  /// Sends what was recorded since the last send.
  Future<void> flush() async {
    final payload = takePayload();
    if (payload == null) return;
    try {
      await send(payload);
    } catch (_) {
      // A heatmap is a sample: a failed send is dropped.
    }
  }
}
