import 'package:flutter/widgets.dart';

class PageViewEvent {
  const PageViewEvent({
    required this.navigationType,
    required this.toRoute,
    required this.previousRoute,
  });

  final String navigationType;
  final RouteSettings? toRoute;
  final RouteSettings? previousRoute;

  PageViewEvent copyWith({
    String? navigationType,
    RouteSettings? toRoute,
    RouteSettings? previousRoute,
  }) {
    return PageViewEvent(
      navigationType: navigationType ?? this.navigationType,
      toRoute: toRoute ?? this.toRoute,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'navigation_type': navigationType,
      'to_route': toRoute?.name,
      'previous_route': previousRoute?.name,
    };
  }
}
