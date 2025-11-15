import 'package:flutter_timezone_observer/flutter_timezone_observer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The abstract platform interface for the `flutter_timezone_observer` plugin.
///
/// This interface defines the contract that all platform-specific
/// implementations must adhere to. It uses a token-based system to
/// ensure that only registered implementations can be used.
///
/// Implementations of this interface
/// should extend [FlutterTimezoneObserverPlatform]
/// rather than implementing it directly.
abstract class FlutterTimezoneObserverPlatform extends PlatformInterface {
  /// Constructs a [FlutterTimezoneObserverPlatform].
  FlutterTimezoneObserverPlatform() : super(token: _token);

  static final _token = Object();

  static FlutterTimezoneObserverPlatform _instance =
      MethodChannelFlutterTimezoneObserver();

  /// The singleton instance of the [FlutterTimezoneObserverPlatform].
  ///
  /// This is the entry point for the platform-specific implementation.
  static FlutterTimezoneObserverPlatform get instance => _instance;

  /// Sets the platform-specific instance of [FlutterTimezoneObserverPlatform].
  ///
  /// This is primarily used for testing, allowing a mock implementation
  /// to be provided.
  static set instance(FlutterTimezoneObserverPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Fetches the current IANA timezone name from the native platform.
  ///
  /// Platform implementations must override this getter to provide
  /// the device's current timezone.
  Future<String> get currentTimezone =>
      throw UnimplementedError('currentTimezone has not been implemented.');

  /// A [Stream] that emits the new IANA timezone name whenever
  /// the device's timezone is changed.
  ///
  /// Platform implementations must override this getter to provide
  /// a stream of timezone change events.
  Stream<String> get onTimezoneChanged =>
      throw UnimplementedError('onTimezoneChanged has not been implemented.');
}
