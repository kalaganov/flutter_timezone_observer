import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  final initialPlatform = FlutterTimezoneObserverPlatform.instance;

  setUp(() {
    final dummyPlatform = DummyPlatform();
    FlutterTimezoneObserverPlatform.instance = dummyPlatform;
  });

  tearDown(() {
    FlutterTimezoneObserverPlatform.instance = initialPlatform;
  });

  test('currentTimezone throws UnimplementedError by default', () async {
    expect(
      () => FlutterTimezoneObserver.currentTimezone,
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('onTimezoneChanged throws UnimplementedError by default', () async {
    expect(
      () => FlutterTimezoneObserver.onTimezoneChanged,
      throwsA(isA<UnimplementedError>()),
    );
  });
}

class DummyPlatform extends FlutterTimezoneObserverPlatform
    with MockPlatformInterfaceMixin {}
