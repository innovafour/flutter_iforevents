/// Session attribution (iforevents-sdks CONTRACT.md, "Attribution"): the
/// utm parameters, ad click ids and external referring domain a visit
/// arrived with, attached as event properties to every event of that
/// session so the IForevents api can split any report by origin
/// ($channel, $source, $utm_campaign, ...).
library;

/// The utm parameters, attached under their own names.
const List<String> utmKeys = [
  'utm_source',
  'utm_medium',
  'utm_campaign',
  'utm_term',
  'utm_content',
  'utm_id',
];

/// Ad platform click ids, attached under their own names.
const List<String> clickIdKeys = [
  'gclid',
  'gbraid',
  'wbraid',
  'dclid',
  'msclkid',
  'fbclid',
  'ttclid',
  'twclid',
  'li_fat_id',
  'epik',
  'sccid',
  'rdt_cid',
  'yclid',
];

/// A session ends after this long without an event.
const Duration attributionSession = Duration(minutes: 30);

const int _maxValue = 512;

String _host(Uri? uri) {
  final host = (uri?.host ?? '').toLowerCase();
  return host.startsWith('www.') ? host.substring(4) : host;
}

/// The attribution of a landing: the utm and click id parameters of [uri]
/// (a deep link such as `myapp://promo?utm_source=x`, or a universal link)
/// plus `referring_domain` when [referrer] is another site. Empty for a
/// landing that carries none.
Map<String, String> attributionFromUri(Uri uri, {Uri? referrer}) {
  final out = <String, String>{};
  Map<String, String> params;
  try {
    params = uri.queryParameters;
  } catch (_) {
    params = const {};
  }
  for (final key in [...utmKeys, ...clickIdKeys]) {
    final value = params[key]?.trim();
    if (value != null && value.isNotEmpty) {
      out[key] = value.length > _maxValue
          ? value.substring(0, _maxValue)
          : value;
    }
  }
  final refHost = _host(referrer);
  if (refHost.isNotEmpty && refHost != _host(uri)) {
    out['referring_domain'] = refHost;
  }
  return out;
}

/// The attribution of an install or campaign referrer string, such as the
/// Google Play install referrer `utm_source=google-play&utm_medium=organic`.
Map<String, String> attributionFromQuery(String query) {
  final q = query.startsWith('?') ? query.substring(1) : query;
  try {
    return attributionFromUri(Uri.parse('x://x?$q'));
  } catch (_) {
    return const {};
  }
}

/// Holds the current session's attribution and attaches it to events.
class AttributionTracker {
  AttributionTracker({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  Map<String, String> _props = const {};
  DateTime? _lastSeen;

  /// The current attribution, empty when the session is direct.
  Map<String, String> get current => Map.unmodifiable(_props);

  /// Starts a new session attribution when [landing] carries any (a deep
  /// link with utm parameters, an install referrer); otherwise keeps the
  /// current one while events arrive within [attributionSession] and drops
  /// it after.
  void touch([Map<String, String> landing = const {}]) {
    final now = _clock();
    if (landing.isNotEmpty) {
      _props = Map.of(landing);
    } else if (_lastSeen == null ||
        now.difference(_lastSeen!) > attributionSession) {
      _props = const {};
    }
    _lastSeen = now;
  }

  /// [properties] with the session attribution added; the caller's own keys
  /// win.
  Map<String, dynamic> apply(
    Map<String, dynamic> properties, [
    Map<String, String> landing = const {},
  ]) {
    touch(landing);
    if (_props.isEmpty) return properties;
    return {..._props, ...properties};
  }

  /// Forgets the attribution (on reset).
  void clear() {
    _props = const {};
    _lastSeen = null;
  }
}
