[![pub package](https://img.shields.io/pub/v/extensions.svg)](https://pub.dev/packages/extensions)
[![package publisher](https://img.shields.io/pub/publisher/extensions.svg)](https://pub.dev/packages/extensions)

# Extensions for Dart

Microsoft.Extensions-style hosting, dependency injection, logging, configuration, and HTTP client plumbing for Dart and Flutter.

## Highlights
- `hosting`: Host builder with graceful startup/shutdown, background services, cancellation tokens, and lifetime notifications.
- `dependency_injection`: Familiar `ServiceCollection` APIs with singleton/scoped/transient lifetimes and validation options.
- `configuration`: Compose JSON, environment variables, command line, INI, XML, in-memory, and stream-based sources with reload support.
- `logging`: Structured logging abstractions with console/debug/json/systemd formatters, filter rules, and scopes.
- `options`: Typed options with validation, change tokens, and monitors.
- `http`: IHttpClientFactory-style pipeline with delegating handlers, logging, handler lifetime control, and header redaction.
- File providers, globbing, caching, and primitives that mirror the .NET ecosystem.

## Install

```sh
dart pub add extensions
```

## Quick start: minimal host with logging

```dart
import 'package:extensions/hosting.dart';

final _builder = Host.createApplicationBuilder()
  ..addLogging((logging) => logging.addSimpleConsole());

final host = _builder.build();

Future<void> main() async => await host.run();
```

## More examples

See `packages/extensions/example` for focused samples (background services, configuration, console formatters, caching, HTTP client logging, and more).

## Related packages

- `extensions_flutter` – bootstraps Flutter with the same host/DI/logging stack.

## Credits

This is a Dart port of the `Microsoft.Extensions.*` stack from the dotnet/runtime repository, adapted where Dart and C# differ.
