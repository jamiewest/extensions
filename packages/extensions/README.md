A set of APIs for commonly used programming patterns and utilities, such as dependency injection, logging, and configuration.

[![pub package](https://img.shields.io/pub/v/extensions.svg)](https://pub.dev/packages/extensions)
[![Build Status](https://github.com/jamiewest/extensions/workflows/Dart/badge.svg)](https://github.com/jamiewest/extensions/actions?query=workflow%3A"Dart"+branch%main)

## Using

```dart
import 'package:extensions/hosting.dart' 

Future<void> main(List<String> args) async =>
    await Host.createDefaultBuilder(args)
        .useConsoleLifetime()
        .build()
        .run();
```

Extensions is a derived work of the [dotnet/runtime](https://github.com/dotnet/runtime) 


