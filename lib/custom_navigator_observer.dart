import 'package:flutter/material.dart';

typedef OnRouteChange<R extends Route<dynamic>> = void Function(
    R route, R? previousRoute);
typedef OnRouteReplace<R extends Route<dynamic>> = void Function(
    R? newRoute, R? oldRoute);

/// навеяно https://medium.com/@payam_zahedi/flutter-navigator-middleware-part-2-middleware-service-class-c9035f4fff68
class CustomNavigatorObserver extends NavigatorObserver {
  final OnRouteChange? onPush;
  final OnRouteChange? onPop;
  final OnRouteChange? onRemove;
  final OnRouteReplace? onReplace;
  final OnRouteChange? onStartUserGesture;
  final VoidCallback? onStopUserGesture;

  CustomNavigatorObserver(
      {this.onPush,
      this.onPop,
      this.onRemove,
      this.onReplace,
      this.onStartUserGesture,
      this.onStopUserGesture});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPush?.call(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop?.call(route, previousRoute);
  }

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onRemove?.call(route, previousRoute);
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onReplace?.call(newRoute, oldRoute);
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    onStartUserGesture?.call(route, previousRoute);
  }

  void didStopUserGesture() {
    onStopUserGesture?.call();
  }
}
