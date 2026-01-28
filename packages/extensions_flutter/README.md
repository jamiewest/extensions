[![pub package](https://img.shields.io/pub/v/extensions_flutter.svg)](https://pub.dev/packages/extensions_flutter)
[![package publisher](https://img.shields.io/pub/publisher/extensions_flutter.svg)](https://pub.dev/packages/extensions_flutter)

# Extensions for Flutter

Bootstrap Flutter apps with the same host, dependency injection, configuration, and logging stack provided by the `extensions` package.

## Features

- **Unified hosting model** - Use the same `Host` pipeline for Flutter, CLI, and background services
- **Dependency injection** - Access services throughout your widget tree via `ServiceProvider`
- **Structured logging** - Automatic error capture from `FlutterError.onError` and `PlatformDispatcher.onError`
- **Lifecycle events** - Subscribe to paused, resumed, inactive, hidden, and detached states
- **Widget wrappers** - Compose providers and themes using `wrapWith`

## Installation

```sh
flutter pub add extensions_flutter
```

## Quick Start

```dart
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/material.dart';

final _builder = Host.createApplicationBuilder()
  ..addLogging((logging) => logging.addSimpleConsole())
  ..services.addFlutter((flutter) => flutter.runApp((services) => MyApp()));

final host = _builder.build();

Future<void> main() async => host.run();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello!'))),
    );
  }
}
```

## Widget Wrappers

Use `wrapWith` to add providers, themes, or other ancestor widgets. Wrappers are applied in reverse registration order (last registered becomes outermost):

```dart
services.addFlutter((flutter) {
  flutter
    ..wrapWith((sp, child) => ThemeProvider(child: child))
    ..wrapWith((sp, child) => LocalizationProvider(child: child))
    ..runApp((_) => MyApp());
});
// Widget tree: ThemeProvider → LocalizationProvider → FlutterLifecycleObserver → MyApp
```

The `FlutterLifecycleObserver` is automatically inserted as the innermost wrapper to enable lifecycle event handling.

## Accessing Services

The `runApp` builder receives a `ServiceProvider` for resolving dependencies:

```dart
flutter.runApp((services) {
  final logger = services.getRequiredService<LoggerFactory>()
      .createLogger('MyApp');
  final config = services.getRequiredService<Configuration>();

  return MyApp(logger: logger, config: config);
});
```

## Lifecycle Events

Subscribe to Flutter lifecycle events via `FlutterApplicationLifetime`:

```dart
final lifetime = services.getRequiredService<HostApplicationLifetime>()
    as FlutterApplicationLifetime;

// Handlers execute in reverse registration order (LIFO)
lifetime.applicationPaused.add(() => saveState());
lifetime.applicationResumed.add(() => refreshData());
lifetime.applicationInactive.add(() => pauseAnimations());
lifetime.applicationHidden.add(() => stopBackgroundWork());
lifetime.applicationDetached.add(() => cleanup());
```

## Error Handling

Errors from `FlutterError.onError` and `PlatformDispatcher.onError` are automatically captured and routed through the logging system:

```dart
Host.createApplicationBuilder()
  ..addLogging((logging) {
    logging
      ..addSimpleConsole()
      ..setMinimumLevel(LogLevel.debug);
  })
  ..services.addFlutter((flutter) => flutter.runApp((_) => MyApp()));
```

Unhandled errors are logged at the `critical` level with full stack traces.

## Full Example

```dart
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/material.dart';

final _builder = Host.createApplicationBuilder()
  ..environment.applicationName = 'my_app'
  ..addLogging((logging) => logging.addSimpleConsole())
  ..services.addFlutter((flutter) {
    flutter
      ..wrapWith((sp, child) => _ThemeWrapper(child: child))
      ..runApp((services) => MyApp(services: services));
  });

final host = _builder.build();

Future<void> main() async => host.run();

class _ThemeWrapper extends StatelessWidget {
  const _ThemeWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: child,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.services});
  final ServiceProvider services;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FlutterApplicationLifetime _lifetime;

  @override
  void initState() {
    super.initState();
    _lifetime = widget.services.getRequiredService<HostApplicationLifetime>()
        as FlutterApplicationLifetime;
    _lifetime.applicationPaused.add(_onPaused);
    _lifetime.applicationResumed.add(_onResumed);
  }

  @override
  void dispose() {
    _lifetime.applicationPaused.remove(_onPaused);
    _lifetime.applicationResumed.remove(_onResumed);
    super.dispose();
  }

  void _onPaused() => debugPrint('App paused');
  void _onResumed() => debugPrint('App resumed');

  @override
  Widget build(BuildContext context) {
    final env = widget.services.getRequiredService<HostEnvironment>();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(env.applicationName)),
        body: const Center(child: Text('Hello!')),
      ),
    );
  }
}
```

## API Reference

### FlutterBuilder Extensions

| Method | Description |
|--------|-------------|
| `runApp(builder)` | Registers the root widget and sets up the Flutter host lifetime |
| `wrapWith(factory)` | Adds a widget wrapper applied in reverse registration order |
| `configure(options)` | Configures Flutter lifetime options |

### FlutterApplicationLifetime

| Property | Description |
|----------|-------------|
| `applicationPaused` | Callbacks invoked when app is paused |
| `applicationResumed` | Callbacks invoked when app resumes |
| `applicationInactive` | Callbacks invoked when app becomes inactive |
| `applicationHidden` | Callbacks invoked when app is hidden |
| `applicationDetached` | Callbacks invoked when app is detached |

### Registered Services

| Service | Description |
|---------|-------------|
| `HostApplicationLifetime` | Access lifecycle events (cast to `FlutterApplicationLifetime`) |
| `ApplicationLifetime` | Base lifetime for start/stop events |
| `ErrorHandler` | Centralized error handling |
| `HostLifetime` | Flutter host lifetime implementation |
| `Widget` | The composed root widget |
