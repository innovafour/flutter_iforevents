import 'package:flutter/widgets.dart';

class PageViewEvent {
  const PageViewEvent({
    required this.navigationType,
    required this.toRoute,
    required this.previousRoute,
    this.properties = const {},
  });

  final String navigationType;
  final RouteSettings? toRoute;
  final RouteSettings? previousRoute;

  /// Extra properties sent with the view (the session attribution).
  final Map<String, dynamic> properties;

  PageViewEvent copyWith({
    String? navigationType,
    RouteSettings? toRoute,
    RouteSettings? previousRoute,
    Map<String, dynamic>? properties,
  }) {
    return PageViewEvent(
      navigationType: navigationType ?? this.navigationType,
      toRoute: toRoute ?? this.toRoute,
      previousRoute: previousRoute ?? this.previousRoute,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...properties,
      'navigation_type': navigationType,
      'to_route': toRoute?.name,
      'previous_route': previousRoute?.name,
    };
  }
}
