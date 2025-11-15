import 'dart:async' show StreamSubscription;

import 'package:flutter/widgets.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer.dart';

/// An advanced mixin for [StatefulWidget]s that manages listening to system
/// timezone changes, incorporating the app's lifecycle.
///
/// This mixin automatically:
/// 1. Fetches the initial timezone in [initState].
/// 2. Subscribes to the [FlutterTimezoneObserver.onTimezoneChanged] stream.
/// 3. Uses [AppLifecycleListener] to **re-fetch** the timezone *only*
///    when the app resumes from a paused state.
/// 4. **Ignores** stream events received while the app is paused, unless
///    [emitTimezoneWhenPaused] is overridden to `true`.
/// 5. Safely cancels the stream subscription and disposes the listener
///    in [dispose].
/// 6. Provides a hook [onTimezoneChanged] for the [State] to react to updates.
mixin AppLifecycleAwareTimezoneObserverMixin<T extends StatefulWidget>
    on State<T> {
  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<String>? _subscription;
  String? _currentZone;

  bool _wasPaused = false;

  /// The most recently received timezone name.
  ///
  /// This value is updated *before* [onTimezoneChanged] is called.
  /// It will be `null` until the initial timezone is fetched.
  String? get currentZone => _currentZone;

  @override
  void initState() {
    super.initState();
    _fetchTimezone();

    _subscription = FlutterTimezoneObserver.onTimezoneChanged.listen(_onData);

    _lifecycleListener = AppLifecycleListener(
      onPause: _onPause,
      onResume: _onResume,
    );
  }

  void _onPause() => _wasPaused = true;

  void _onResume() {
    if (!_wasPaused) return;
    _fetchTimezone();
    _wasPaused = false;
  }

  void _fetchTimezone() =>
      FlutterTimezoneObserver.currentTimezone.then(_onData);

  void _onData(String zone) {
    if (!mounted) return;
    if (_wasPaused && !emitTimezoneWhenPaused) return;
    if (zone == _currentZone) return;

    _currentZone = zone;
    onTimezoneChanged(zone);
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  /// A flag to control if [onTimezoneChanged] should be called
  /// when a stream event is received while the app is paused.
  ///
  /// Defaults to `false`. Override this in your [State]
  /// if you need to process timezone events in the background.
  @protected
  bool get emitTimezoneWhenPaused => false;

  /// A hook for the [State] to implement.
  ///
  /// This method is called with the initial timezone value
  /// and subsequently every time the system timezone changes
  /// or the app resumes from the background with a new timezone.
  @protected
  void onTimezoneChanged(String newZone);
}
