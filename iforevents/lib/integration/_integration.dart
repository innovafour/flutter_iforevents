import 'dart:developer';
import 'package:iforevents/models/integration.dart';

export 'package:iforevents/models/integration.dart';

/// Result of integration execution
class IntegrationResult {
  final String integrationName;
  final bool success;
  final String? error;
  final DateTime timestamp;

  const IntegrationResult({
    required this.integrationName,
    required this.success,
    this.error,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'IntegrationResult(name: $integrationName, success: $success, error: $error)';
  }
}

class IntegrationFactory {
  static List<Integration> integrations = [];

  static Future<List<IntegrationResult>> init({
    List<Integration> integrations = const [],
  }) async {
    IntegrationFactory.integrations = integrations;
    final results = <IntegrationResult>[];

    for (final integration in integrations) {
      final result = await safeExecute(() => integration.init(), integration);
      results.add(result);
    }

    return results;
  }

  static Future<List<IntegrationResult>> identify({
    required String customID,
    required Map<String, dynamic> identifyData,
  }) async {
    final results = <IntegrationResult>[];

    for (final integration in integrations) {
      final result = await safeExecute(
        () => integration.identify(
          event: IdentifyEvent(customID: customID, properties: identifyData),
        ),
        integration,
      );
      results.add(result);
    }

    return results;
  }

  static Future<List<IntegrationResult>> track({
    required TrackEvent event,
  }) async {
    final results = <IntegrationResult>[];

    for (final integration in integrations) {
      final result = await safeExecute(
        () => integration.track(event: event),
        integration,
      );
      results.add(result);
    }

    return results;
  }

  static Future<List<IntegrationResult>> reset() async {
    final results = <IntegrationResult>[];

    for (final integration in integrations) {
      final result = await safeExecute(integration.reset, integration);
      results.add(result);
    }

    return results;
  }

  static Future<List<IntegrationResult>> pageViewed({
    required PageViewEvent event,
  }) async {
    final results = <IntegrationResult>[];

    for (final integration in integrations) {
      final result = await safeExecute(
        () => integration.pageView(event: event),
        integration,
      );
      results.add(result);
    }

    return results;
  }

  static Future<IntegrationResult> safeExecute(
    Function function,
    Integration integration,
  ) async {
    try {
      await function();
      return IntegrationResult(
        integrationName: integration.runtimeType.toString(),
        success: true,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      log('Error in integration ${integration.runtimeType}: $e');
      return IntegrationResult(
        integrationName: integration.runtimeType.toString(),
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// Executes a specific integration by name
  static Future<IntegrationResult?> executeSpecificIntegration(
    String integrationName,
    Function(Integration) action,
  ) async {
    try {
      final integration = integrations.firstWhere(
        (i) => i.runtimeType.toString() == integrationName,
      );

      return await safeExecute(() => action(integration), integration);
    } catch (e) {
      log('Integration not found: $integrationName');
      return null;
    }
  }
}
