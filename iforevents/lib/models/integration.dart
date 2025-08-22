import 'package:iforevents/models/event.dart';
import 'package:flutter/widgets.dart';

class Integration {
  const Integration();

  Future<void> init() async {}

  Future<void> identify({
    required String id,
    required Map<String, dynamic> data,
  }) async {}

  Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {}

  Future<void> reset() async {}

  Future<void> pageView({
    required RouteSettings? toRoute,
    required RouteSettings? previousRoute,
  }) async {}
}
