import 'package:flutter_timezone_observer/flutter_timezone_observer_platform_interface.dart';

/// A static class to retrieve and observe the system's timezone.
///
/// This class provides a simple API to access the device's
/// current IANA timezone name (e.g., 'Europe/London' or 'America/New_York').
abstract final class FlutterTimezoneObserver {
  /// Fetches the current IANA timezone name from the native platform.
  ///
  /// This is a single-read getter, ideal for fetching the
  /// timezone once during application initialization.
  static Future<String> get currentTimezone =>
      FlutterTimezoneObserverPlatform.instance.currentTimezone;

  /// A [Stream] that emits the new IANA timezone name whenever
  /// the device's timezone is changed by the user or system.
  static Stream<String> get onTimezoneChanged =>
      FlutterTimezoneObserverPlatform.instance.onTimezoneChanged;
}
