import 'package:iforevents/models/event.dart';
import 'package:flutter/widgets.dart';
import 'package:iforevents/models/identify.dart';

export 'package:iforevents/models/event.dart';
export 'package:iforevents/models/identify.dart';

class Integration<T> {
  const Integration({this.onInit, this.onIdentify, this.onTrack, this.onReset});

  final void Function()? onInit;
  final void Function()? onReset;
  final void Function(IdentifyEvent event)? onIdentify;
  final void Function(IdentifyEvent event)? onTrack;

  Future<void> init() async {}

  Future<void> identify({required IdentifyEvent event}) async {}

  Future<void> track({required TrackEvent event}) async {}

  Future<void> reset() async {}

  Future<void> pageView({
    required RouteSettings? toRoute,
    required RouteSettings? previousRoute,
  }) async {}
}
