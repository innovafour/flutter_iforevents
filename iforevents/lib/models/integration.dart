import 'package:flutter/widgets.dart';
import 'package:iforevents/models/event.dart';
import 'package:iforevents/models/identify.dart';
import 'package:iforevents/models/pageview.dart';

export 'package:iforevents/models/event.dart';
export 'package:iforevents/models/identify.dart';
export 'package:iforevents/models/pageview.dart';

class Integration<T> {
  const Integration({
    this.onInit,
    this.onIdentify,
    this.onTrack,
    this.onReset,
    this.onPageView,
  });

  final void Function()? onInit;
  final void Function()? onReset;
  final void Function(IdentifyEvent event)? onIdentify;
  final void Function(TrackEvent event)? onTrack;
  final void Function(PageViewEvent event)? onPageView;

  @mustCallSuper
  Future<void> init() async {
    if (onInit != null) {
      onInit!();
    }
  }

  @mustCallSuper
  Future<void> identify({required IdentifyEvent event}) async {
    if (onIdentify != null) {
      onIdentify!(event);
    }
  }

  @mustCallSuper
  Future<void> track({required TrackEvent event}) async {
    if (onTrack != null) {
      onTrack!(event);
    }
  }

  @mustCallSuper
  Future<void> reset() async {
    if (onReset != null) {
      onReset!();
    }
  }

  @mustCallSuper
  Future<void> pageView({required PageViewEvent event}) async {
    if (onPageView != null) {
      onPageView!(event);
    }
  }
}
