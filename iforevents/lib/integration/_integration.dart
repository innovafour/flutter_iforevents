import 'package:iforevents/models/event.dart';
import 'package:iforevents/models/integration.dart';
import 'package:flutter/widgets.dart';

export 'package:iforevents/models/integration.dart';

class IntegrationFactory {
  static List<Integration> integrations = [];

  static Future<void> init({List<Integration> integrations = const []}) async {
    final awaitables = <Future>[];

    for (final integration in integrations) {
      awaitables.add(safeExecute(() => integration.init(), integration));
    }

    await Future.wait(awaitables);
  }

  static Future<void> identify({
    required String id,
    required Map<String, dynamic> identifyData,
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.identify(id: id, data: identifyData),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.track(
            eventName: eventName,
            eventType: eventType,
            properties: properties,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> reset() async {
    final awaitables = <Future>[];

    for (final integration in integrations) {
      awaitables.add(safeExecute(integration.reset, integration));
    }

    await Future.wait(awaitables);
  }

  static Future<void> screen({
    required RouteSettings? toRoute,
    required RouteSettings? previousRoute,
  }) async {
    final awaitables = <Future>[];

    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.pageView(
            toRoute: toRoute,
            previousRoute: previousRoute,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> safeExecute(
    Function function,
    Integration integration,
  ) async {
    try {
      await function();
    } catch (e) {
      return;
    }
  }
}
