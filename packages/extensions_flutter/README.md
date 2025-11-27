[![pub package](https://img.shields.io/pub/v/extensions_flutter.svg)](https://pub.dev/packages/extensions_flutter)
[![package publisher](https://img.shields.io/pub/publisher/extensions_flutter.svg)](https://pub.dev/packages/extensions_flutter)

# Extensions for Flutter

Bootstrap Flutter apps with the same host, dependency injection, configuration, and logging stack provided by the `extensions` package.

## What it adds
- `addFlutter` wires up Flutter-specific lifetimes, runApp, and graceful shutdown using the shared host pipeline.
- Automatic error capture from `FlutterError.onError` and `PlatformDispatcher.onError`, routed through `Logger`.
- `FlutterApplicationLifetime` publishes paused, resumed, inactive, hidden, and detached events via `WidgetsBindingObserver`.
- Access to `Host.configuration`, `Host.environment`, and typed loggers inside widgets through the provided extensions.

## Install

```sh
flutter pub add extensions_flutter
```

## Quick start: host-driven Flutter bootstrap

```dart
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/widgets.dart';

final _builder = Host.createApplicationBuilder()
  ..addLogging((logging) => logging.addSimpleConsole())
  ..addFlutter((flutter) => flutter.useApp((services) => MyApp()));

final host = _builder.build();

Future<void> main() async => host.run();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return Text('Hi');
  }
}
```

The Flutter host wraps your root widget with a lifecycle observer and keeps logging/configuration consistent across Flutter, CLI, and background service entry points.
