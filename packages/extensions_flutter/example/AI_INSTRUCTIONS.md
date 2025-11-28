# Host-driven Flutter bootstrap (for an AI to follow)

Goal: build everything through the `Host`, register app services on `ServiceCollection`, wire Flutter with `addFlutter`, then resolve services inside widgets. Keep `runApp` inside the host pipeline.

## Minimal host setup
- Create the builder: `final builder = Host.createApplicationBuilder();`
- Configure infra before build: `builder.services.addLogging((logging) => logging.addSimpleConsole());`
- Register your app services on `builder.services` (see `add{ServiceName}` pattern below).
- Add Flutter and wrap the root widget: `builder.services.addFlutter((flutter) => flutter.useApp((sp) => MyApp(services: sp)));`
- Build and run: `final host = builder.build(); Future<void> main() async => host.run();`

## ServiceCollection extension pattern (`add{ServiceName}`)
Teach the AI to create extensions so root configuration reads cleanly, e.g. `services.addCounterService((options) => options.startingValue = 0);`

Example: a `Counter` service with options.
```dart
class CounterOptions {
  int startingValue = 0;
}

class Counter {
  Counter({required int startingValue}) : value = ValueNotifier<int>(startingValue);
  final ValueNotifier<int> value;
  void increment() => value.value++;
}

extension CounterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addCounterService([void Function(CounterOptions)? configure]) {
    addSingleton<CounterOptions>((_) {
      final options = CounterOptions();
      configure?.call(options);
      return options;
    });

    addSingleton<Counter>((sp) {
      final options = sp.getRequiredService<CounterOptions>();
      return Counter(startingValue: options.startingValue);
    });

    return this;
  }
}
```

## Using the extension in the host
```dart
final builder = Host.createApplicationBuilder()
  ..services
      .addLogging((logging) => logging.addSimpleConsole())
      .addCounterService((options) => options.startingValue = 0)
      .addFlutter((flutter) => flutter.useApp((sp) => MyApp(services: sp)));

final host = builder.build();
Future<void> main() async => host.run();
```

## Consuming services in UI code
Inside the root widget, resolve services from the provided `ServiceProvider` and listen to state changes.
```dart
class MyApp extends StatelessWidget {
  final ServiceProvider services;
  const MyApp({required this.services, super.key});

  @override
  Widget build(BuildContext context) {
    final counter = services.getRequiredService<Counter>();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Host + Flutter')),
        body: Center(
          child: ValueListenableBuilder<int>(
            valueListenable: counter.value,
            builder: (_, count, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Count: $count'),
                ElevatedButton(
                  onPressed: counter.increment,
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Notes for the AI:
- Keep all registrations on the builder before `build()`.
- Use `ServiceProvider` to resolve services; do not new-up inside widgets.
- Keep `runApp` inside `addFlutter(...useApp(...))` so lifetimes, logging, and configuration stay consistent.
