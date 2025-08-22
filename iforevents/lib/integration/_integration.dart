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
    required String customID,
    required Map<String, dynamic> identifyData,
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.identify(
            event: IdentifyEvent(customID: customID, properties: identifyData),
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> track({required TrackEvent event}) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(() => integration.track(event: event), integration),
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
