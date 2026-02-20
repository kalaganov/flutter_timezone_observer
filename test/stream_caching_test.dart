import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone_observer/app_lifecycle_aware_timezone_observer_mixin.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_method_channel.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  test('onTimezoneChanged returns the same Stream instance on repeated calls',
      () {
    final platform = MethodChannelFlutterTimezoneObserver();

    final stream1 = platform.onTimezoneChanged;
    final stream2 = platform.onTimezoneChanged;

    expect(identical(stream1, stream2), isTrue);
  });

  group('Widget recreation does not break stream subscription', () {
    late MockPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockPlatform();
      FlutterTimezoneObserverPlatform.instance = mockPlatform;
    });

    testWidgets(
      'dispose and recreate widget without errors',
      (tester) async {
        await tester.pumpWidget(const TestApp(showObserver: true));
        await tester.pumpAndSettle();

        final state1 = tester.state<TestObserverState>(
          find.byType(TestObserver),
        );
        expect(state1.lastZone, 'Mock/Initial');

        await tester.pumpWidget(const TestApp(showObserver: false));
        await tester.pumpAndSettle();
        expect(find.byType(TestObserver), findsNothing);

        await tester.pumpWidget(const TestApp(showObserver: true));
        await tester.pumpAndSettle();

        final state2 = tester.state<TestObserverState>(
          find.byType(TestObserver),
        );
        expect(state2.lastZone, 'Mock/Initial');

        mockPlatform.streamController.add('Europe/Berlin');
        await tester.pumpAndSettle();
        expect(state2.lastZone, 'Europe/Berlin');
      },
    );

    testWidgets(
      'rapid dispose-recreate cycles complete without errors',
      (tester) async {
        for (var i = 0; i < 5; i++) {
          await tester.pumpWidget(const TestApp(showObserver: true));
          await tester.pumpAndSettle();
          await tester.pumpWidget(const TestApp(showObserver: false));
          await tester.pumpAndSettle();
        }

        await tester.pumpWidget(const TestApp(showObserver: true));
        await tester.pumpAndSettle();

        final state = tester.state<TestObserverState>(
          find.byType(TestObserver),
        );
        expect(state.lastZone, 'Mock/Initial');

        mockPlatform.streamController.add('Asia/Tokyo');
        await tester.pumpAndSettle();
        expect(state.lastZone, 'Asia/Tokyo');
      },
    );
  });
}

class MockPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTimezoneObserverPlatform {
  final streamController = StreamController<String>.broadcast();
  String initialTimezone = 'Mock/Initial';

  @override
  Future<String> get currentTimezone =>
      Future.delayed(const Duration(milliseconds: 1), () => initialTimezone);

  @override
  Stream<String> get onTimezoneChanged => streamController.stream;
}

class TestApp extends StatelessWidget {
  const TestApp({required this.showObserver, super.key});

  final bool showObserver;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: showObserver ? const TestObserver() : const SizedBox.shrink(),
    );
  }
}

class TestObserver extends StatefulWidget {
  const TestObserver({super.key});

  @override
  State<TestObserver> createState() => TestObserverState();
}

class TestObserverState extends State<TestObserver>
    with AppLifecycleAwareTimezoneObserverMixin {
  String? lastZone;

  @override
  void onTimezoneChanged(String newZone) {
    lastZone = newZone;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(currentZone ?? 'Loading');
  }
}
