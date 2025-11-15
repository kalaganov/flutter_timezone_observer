import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_method_channel.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  final initialPlatform = FlutterTimezoneObserverPlatform.instance;

  late MockFlutterTimezoneObserverPlatform fakePlatform;

  setUp(() {
    fakePlatform = MockFlutterTimezoneObserverPlatform();
    FlutterTimezoneObserverPlatform.instance = fakePlatform;
  });

  tearDown(() {
    FlutterTimezoneObserverPlatform.instance = initialPlatform;
  });

  test('$MethodChannelFlutterTimezoneObserver is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterTimezoneObserver>(),
    );
  });

  test('currentTimezone returns value from platform', () async {
    expect(await FlutterTimezoneObserver.currentTimezone, 'Mock/Timezone');
  });

  test('onTimezoneChanged returns stream from platform', () {
    expect(
      FlutterTimezoneObserver.onTimezoneChanged,
      emitsInOrder(['Europe/London', 'America/New_York']),
    );
  });
}

class MockFlutterTimezoneObserverPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTimezoneObserverPlatform {
  @override
  Future<String> get currentTimezone => Future.value('Mock/Timezone');

  @override
  Stream<String> get onTimezoneChanged {
    return Stream.fromIterable(['Europe/London', 'America/New_York']);
  }
}
