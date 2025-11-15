/// @docImport 'package:flutter_timezone_observer/app_lifecycle_aware_timezone_observer_mixin.dart';
library;

import 'dart:async';
import 'package:flutter/widgets.dart' show State, StatefulWidget, protected;
import 'package:flutter_timezone_observer/flutter_timezone_observer.dart';

/// A mixin for [StatefulWidget]s to automatically manage
/// listening to system timezone changes.
///
/// This mixin handles:
/// 1. Fetches the initial timezone in [initState].
/// 2. Subscribes to the [FlutterTimezoneObserver.onTimezoneChanged] stream.
/// 3. Safely cancels the stream subscription in [dispose].
/// 4. Provides a hook [onTimezoneChanged] for the [State] to react to updates.
///
/// ---
///
/// **Note:** This mixin does *not* re-fetch the timezone when the app
/// resumes from the background.
///
/// For a more robust solution that also handles app lifecycle events,
/// consider using [AppLifecycleAwareTimezoneObserverMixin].
mixin TimezoneObserverMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<String>? _subscription;
  String? _currentZone;

  /// The most recently received timezone name.
  ///
  /// This value is updated *before* [onTimezoneChanged] is called.
  /// It will be `null` until the initial timezone is fetched.
  String? get currentZone => _currentZone;

  @override
  void initState() {
    super.initState();

    FlutterTimezoneObserver.currentTimezone.then(_onData);

    _subscription = FlutterTimezoneObserver.onTimezoneChanged.listen(_onData);
  }

  void _onData(String zone) {
    if (!mounted) return;
    if (zone == _currentZone) return;
    _currentZone = zone;
    onTimezoneChanged(zone);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// A hook for the [State] to implement.
  ///
  /// This method is called with the initial timezone value
  /// and subsequently every time the system timezone changes.
  @protected
  void onTimezoneChanged(String newZone);
}
