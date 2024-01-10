A set of APIs for commonly used programming patterns and utilities, such as dependency injection, logging, and configuration.

[![pub package](https://img.shields.io/pub/v/extensions.svg)](https://pub.dev/packages/extensions)
[![Build Status](https://github.com/jamiewest/extensions/workflows/Dart/badge.svg)](https://github.com/jamiewest/extensions/actions?query=workflow%3A"Dart"+branch%main)

## Configuration
```dart
import 'package:extensions/configuration.dart';

void main() {
  var configurationBuilder = ConfigurationBuilder()
    // Adds a memory collection to the configuration system.
    ..addInMemoryCollection(
      <String, String>{
        'Logging:LogLevel:Default': 'Warning',
      }.entries,
    );

  var config = configurationBuilder.build();
  print(config['Logging:LogLevel:Default']);
}
```

## Dependency Injection
```dart
import 'package:extensions/dependency_injection.dart';

void main() {
  var serviceCollection = ServiceCollection();
  serviceCollection.addSingleton<MyService>(
    implementationInstance: MyService(),
  );
  var services = serviceCollection.buildServiceProvider();
  var myService = services.getRequiredService<MyService>();
}
```

## Logging
`package:extensions/logging.dart' provides a class [`LoggerFactory`][LoggerFactory] to create a [`Logger`][Logger] for a specific category.
```dart
import 'package:extensions/logging.dart';

void main() {
  LoggerFactory.create(
    (builder) => builder
    ..addDebug()
    ..setMinimumLevel(LogLevel.debug),
  ).createLogger('MyLogger').logDebug('Hello World');
}
```
The preceeding code uses the [LoggerFactory] static method [`create`][LoggerFactory.create] to create a [`Logger`][Logger]. The output is displayed in the debug window and looks like this:
```
[MyLogger] LogLevel.debug: Hello World
```


## Generic Host
```dart
import 'package:extensions/hosting.dart' 

Future<void> main(List<String> args) async =>
    await Host.createDefaultBuilder(args)
        .useConsoleLifetime()
        .build()
        .run();
```

Extensions is a derived work of the [dotnet/runtime](https://github.com/dotnet/runtime) 


Interfaces will follow the .NET convention of using 'I' as a prefix to interfaces. These will be placed in a file using the name without the 'I' (ex. IMyInterface would be saved as `my_interface.dart`). Implementations using the same name would also reside in that file.

Since we cannot do constructor or method overloading, we will be using named parameters where appropriate. 

Static only helper classes will be permitted.

Strings.resx will be included and source_gen'd.

