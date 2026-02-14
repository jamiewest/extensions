# AI Instructions: extensions + extensions_flutter

These are instructions for an ai that will be using the extensions, extensions_flutter
and extensions_flutter_services packages.

These packages implement a .NET-style hosting, DI, logging, and configuration stack for Dart, with Flutter integration layered on top. The core package (`extensions`) is useful on its own, but the full value appears when you combine it with `extensions_flutter` to run a Flutter app inside the same host pipeline.

## Package map
- `extensions`: hosting, dependency injection, logging, configuration, options, HTTP client plumbing, caching, and primitives.
- `extensions_flutter`: Flutter host integration (`addFlutter`, `runApp`, widget wrappers, lifecycle, error capture).

## Core mental model
1. Create a `HostApplicationBuilder`.
2. Configure logging, configuration, and services on the builder.
3. For Flutter, register Flutter support and the root widget with `addFlutter`.
4. Build the host once and run it.

## Minimal combined setup (preferred pattern)
```dart
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/material.dart';

final builder = Host.createApplicationBuilder()
  ..addLogging((logging) => logging.addSimpleConsole())
  ..services.addFlutter((flutter) {
    flutter
      ..wrapWith((sp, child) => Theme(data: ThemeData.dark(), child: child))
      ..runApp((sp) => MyApp(services: sp));
  });

final host = builder.build();

Future<void> main() async => host.run();

class MyApp extends StatelessWidget {
  const MyApp({required this.services, super.key});
  final ServiceProvider services;

  @override
  Widget build(BuildContext context) {
    final logger = services.createLogger('MyApp');
    logger.logInformation('App build');
    return const MaterialApp(home: Scaffold(body: Text('Hello')));
  }
}
```

## Use the Host consistently
- Register everything before `build()`; treat the host as immutable after build.
- Prefer `Host.createApplicationBuilder()` for Flutter apps.
- For CLI/background apps, `Host.createDefaultBuilder()` plus `useConsoleLifetime()` is the common pattern.

## Service registration pattern
Use `ServiceCollection` extension methods to keep bootstrapping clean.
```dart
extension CounterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addCounterService() {
    addSingleton<Counter>(() => Counter());
    return this;
  }
}
```

Then in the host:
```dart
builder.services
  .addCounterService()
  .addFlutter((flutter) => flutter.runApp((sp) => MyApp(services: sp)));
```

## Accessing services in Flutter
- Resolve services via the `ServiceProvider` passed into `runApp`.
- Do not instantiate services inside widgets; request them from DI.
- `ServiceProviderExtensions.createLogger` is a convenience to create a logger.
- If you need `services.getRequiredService<MyService>()`, resolve it once in a `StatefulWidget` (e.g. in `initState`) and store it in a field so rebuilds don't repeatedly resolve it.
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({required this.services, super.key});
  final ServiceProvider services;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final MyService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.services.getRequiredService<MyService>();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_service.value);
  }
}
```

## Flutter wrappers and lifecycle
- `wrapWith` adds widget wrappers. Wrappers are applied in reverse registration order (last registered becomes outermost).
- `runApp` automatically inserts a `FlutterLifecycleObserver` as the innermost wrapper.
- Access lifecycle events via `HostApplicationLifetime` cast to `FlutterApplicationLifetime`.

## Hosted/background services (non-UI work)
Use `HostedService`/`BackgroundService` from `extensions` and register them in the host. This allows background tasks to share the same DI, configuration, and logging as the Flutter UI.
```dart
services.addHostedService<MySyncService>((sp) => MySyncService(sp.createLogger('Sync')));
```

## Configuration, options, and logging
- `HostApplicationBuilder` exposes `configuration`, `logging`, and `metrics`.
- Add configuration sources to `builder.configuration` before `build()`.
- Use the `options` pattern for typed settings, and validate if needed.
- Configure log providers via `builder.addLogging((logging) => ...)`.

## When to combine packages
- Use only `extensions` for CLI servers, workers, or non-Flutter apps.
- Add `extensions_flutter` when you want Flutter UI + the same host/DI/logging pipeline.
- The combination lets you share configuration, logging, and background services between Flutter and non-UI tasks.

## Do / Don't for AI-generated code
- Do: keep `runApp` inside `addFlutter(...)` so lifetimes and logging are wired correctly.
- Do: register services and options on the builder before calling `build()`.
- Do: keep service wiring in `ServiceCollection` extensions for clarity and reuse.
- Don't: call `runApp` directly outside the host.
- Don't: create or mutate the host after it has been built.