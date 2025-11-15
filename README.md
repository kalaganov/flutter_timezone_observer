# flutter_timezone_observer

A Flutter package for accessing the native device timezone (IANA) and observing changes. Includes mixins to automatically handle app lifecycle events.

[![Build Status](https://img.shields.io/github/actions/workflow/status/kalaganov/flutter_timezone_observer/test.yml?branch=main)](https://github.com/kalaganov/flutter_timezone_observer/actions)
[![pub package](https://img.shields.io/pub/v/flutter_timezone_observer.svg)](https://pub.dev/packages/flutter_timezone_observer)
[![codecov](https://codecov.io/github/kalaganov/flutter_timezone_observer/graph/badge.svg?token=J8LEA83TOV)](https://codecov.io/github/kalaganov/flutter_timezone_observer)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![Verified Publisher](https://img.shields.io/pub/publisher/flutter_timezone_observer)](https://pub.dev/packages/flutter_timezone_observer)

---

## Features

* **Get Current Timezone:** One-time async call to get the current IANA timezone (e.g., `America/New_York`).
* **Listen to Changes:** Get a `Stream` of timezone changes broadcast by the native platform.
* **Lifecycle-Aware Mixin:** Includes `AppLifecycleAwareTimezoneObserverMixin` to automatically re-fetch the timezone when the app resumes.
* **Simple Mixin:** Includes a basic `TimezoneObserverMixin` for simple use cases.
* **Minimal:** No external Flutter package dependencies.

---

## How to Use

### 1. One-time Read

Get the current timezone on app start or any time you need it.

```dart
import 'package.flutter_timezone_observer/flutter_timezone_observer.dart';

Future<void> main() async {
  final String timezone = await FlutterTimezoneObserver.currentTimezone;
  print('Current device timezone: $timezone');
  runApp(MyApp());
}
```

### 2. Listen to Stream

Listen to the native broadcast for timezone changes.

```dart
final subscription = FlutterTimezoneObserver.onTimezoneChanged.listen((zone) {
print('Timezone changed: $zone');
});

// Don't forget to cancel
subscription.cancel();
```

### 3. Usage with Lifecycle-Aware Mixin (Recommended)

This is the most reliable way. Use this mixin on your `State` to automatically handle initialization, stream listening, and app-resume logic.

```dart
import 'package.flutter/material.dart';
import 'package:flutter_timezone_observer/app_lifecycle_aware_timezone_observer_mixin.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with AppLifecycleAwareTimezoneObserverMixin {
      
  @override
  void onTimezoneChanged(String newZone) {
    // The mixin handles all the logic.
    // Just call setState to rebuild with the new value.
    setState(() {
      // `currentZone` (from the mixin) is already updated
    });
  }

  @override
  Widget build(BuildContext context) {
    // `currentZone` is provided by the mixin
    return Text(
      'Current Zone: ${currentZone ?? 'Loading...'}',
    );
  }
}
```

### 4. Usage with Simple Mixin (Basic)

If you only care about the stream and don't need the app-resume logic, use `TimezoneObserverMixin`.

```dart
import 'package:flutter_timezone_observer/timezone_observer_mixin.dart';

class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget>
    with TimezoneObserverMixin { // <-- Note: the simple mixin
      
  @override
  void onTimezoneChanged(String newZone) {
    setState(() {});
  }
  
  // ...
}
```

### 5. Advanced: Handling Paused State

By default, `AppLifecycleAwareTimezoneObserverMixin` ignores stream events while the app is paused (to prevent background `setState` calls), as it re-fetches the timezone on resume anyway.

You can override this behavior by setting `emitTimezoneWhenPaused` to `true`.

```dart
import 'package.flutter/material.dart';
import 'package:flutter_timezone_observer/app_lifecycle_aware_timezone_observer_mixin.dart';

class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget>
    with AppLifecycleAwareTimezoneObserverMixin {
      
  // Override the getter to enable background updates
  @override
  bool get emitTimezoneWhenPaused => true;
  
  @override
  void onTimezoneChanged(String newZone) {
    // This will now fire even if the app is paused.
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(
      'Current Zone: ${currentZone ?? 'Loading...'}',
    );
  }
}
```

## Installation
### 1. Add to `pubspec.yaml`
```bash
dart pub add flutter_timezone_observer
```