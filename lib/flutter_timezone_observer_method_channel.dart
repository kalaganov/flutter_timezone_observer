import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_platform_interface.dart';

/// An implementation of [FlutterTimezoneObserverPlatform]
/// that uses method channels.
class MethodChannelFlutterTimezoneObserver
    extends FlutterTimezoneObserverPlatform {
  /// The method channel used to interact with the native platform for
  /// single-read operations.
  final _methodChannel = const MethodChannel(
    'flutter_timezone_observer/methods',
  );

  /// The event channel used to stream timezone changes
  /// from the native platform.
  final _eventChannel = const EventChannel(
    'flutter_timezone_observer/events',
  );

  /// Fetches the current IANA timezone name from the native platform.
  @override
  Future<String> get currentTimezone async {
    try {
      final timezone =
          await _methodChannel.invokeMethod('getLocalTimezone') as String?;
      return timezone ?? 'unknown';
    } on PlatformException catch (e, st) {
      log(
        'Failed to get timezone. Platform error.',
        name: 'FlutterTimezoneObserver',
        error: e,
        stackTrace: st,
      );
      return 'unknown';
    }
  }

  /// A [Stream] that emits the new IANA timezone name whenever
  /// the device's timezone is changed.
  @override
  Stream<String> get onTimezoneChanged =>
      _eventChannel.receiveBroadcastStream().map((event) => '$event');
}
