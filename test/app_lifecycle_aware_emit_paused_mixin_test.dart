import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone_observer/app_lifecycle_aware_timezone_observer_mixin.dart';
import 'package:flutter_timezone_observer/flutter_timezone_observer_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  late MockFlutterTimezoneObserverPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockFlutterTimezoneObserverPlatform();
    FlutterTimezoneObserverPlatform.instance = mockPlatform;
  });

  testWidgets(
    'Mixin initializes, listens to stream, emits when paused',
    (tester) async {
      await tester.pumpWidget(const SimpleTestWidget());
      final state =
          tester.state(find.byType(SimpleTestWidget)) as _SimpleTestWidgetState;

      expect(state.lastHookValue, null);
      expect(find.text('Loading'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(state.lastHookValue, 'Mock/Initial');
      expect(find.text('Mock/Initial'), findsOneWidget);

      mockPlatform.streamController.add('Mock/StreamUpdate');

      await tester.pumpAndSettle();
      expect(state.lastHookValue, 'Mock/StreamUpdate');
      expect(find.text('Mock/StreamUpdate'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(state.lastHookValue, 'Mock/StreamUpdate');
      expect(find.text('Mock/StreamUpdate'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(state.lastHookValue, 'Mock/Initial');
      expect(find.text('Mock/Initial'), findsOneWidget);

      // ------------
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      mockPlatform.initialTimezone = 'Mock/ZoneChanged';
      mockPlatform.streamController.add('Mock/ZoneChanged');
      await tester.pumpAndSettle();

      expect(state.lastHookValue, 'Mock/ZoneChanged');

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(state.lastHookValue, 'Mock/ZoneChanged');
      expect(find.text('Mock/ZoneChanged'), findsOneWidget);
    },
  );
}

class MockFlutterTimezoneObserverPlatform
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

class SimpleTestWidget extends StatefulWidget {
  const SimpleTestWidget({super.key});

  @override
  State<SimpleTestWidget> createState() => _SimpleTestWidgetState();
}

class _SimpleTestWidgetState extends State<SimpleTestWidget>
    with AppLifecycleAwareTimezoneObserverMixin {
  String? lastHookValue;

  @override
  bool get emitTimezoneWhenPaused => true;

  @override
  void onTimezoneChanged(String newZone) {
    lastHookValue = newZone;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Text(
          currentZone ?? 'Loading',
        ),
      ),
    );
  }
}
