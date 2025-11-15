import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelFlutterTimezoneObserver();

  const methodChannel = MethodChannel('flutter_timezone_observer/methods');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('currentTimezone returns value on success', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          methodChannel,
          (MethodCall methodCall) async {
            if (methodCall.method == 'getLocalTimezone') {
              return 'Europe/London';
            }
            return null;
          },
        );

    expect(await platform.currentTimezone, 'Europe/London');
  });

  test('currentTimezone returns "unknown" on PlatformException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          methodChannel,
          (MethodCall methodCall) async {
            if (methodCall.method == 'getLocalTimezone') {
              throw PlatformException(
                code: 'TEST_ERROR',
                message: 'Test error',
              );
            }
            return null;
          },
        );

    expect(await platform.currentTimezone, 'unknown');
  });

  test('onTimezoneChanged getter returns a Stream', () {
    expect(platform.onTimezoneChanged, isA<Stream<String>>());
  });
}
