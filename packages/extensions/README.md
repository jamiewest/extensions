[![pub package](https://img.shields.io/pub/v/extensions.svg)](https://pub.dev/packages/extensions)
[![package publisher](https://img.shields.io/pub/publisher/extensions.svg)](https://pub.dev/packages/extensions)

## .NET Extensions for Dart

A set of APIs for commonly used programming patterns and utilities, such as **dependency injection**, **logging**, and **configuration**.

## Example
```dart
import 'package:extensions/hosting.dart';

Future<void> main(List<String> args) async =>
    await Host.createDefaultBuilder(args)
        .useConsoleLifetime()
        .build()
        .run();
```

## Code Adaptations

The majority of code in this library is taken directly from the dotnet/runtime extension's namespace and aims to be as close a port as possible. However dart and c# dont always mix well. Below are some examples of how this library will handle scenarios that required some code modification.

### Out Parameters

Parameters in dart are passed by value whereas with c# they can be passed by reference using the `out` keyword. In this example, we that the method TryGetValue returns a boolean 

```csharp 
Dictionary<int, long> myDic;

if(myDic.TryGetValue(100, out var lValue))
{
    return lValue;
}
```
