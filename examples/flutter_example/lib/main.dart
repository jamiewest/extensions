import 'package:flutter/material.dart';
import 'package:extensions_flutter/extensions_flutter.dart';

class CounterManager {
  CounterManager() : counter = ValueNotifier(0);
  ValueNotifier<int> counter;
}

final host = Host.createDefaultBuilder()
    .useFlutterLifetime(
  const MyApp(),
  //FlutterLifetimeOptions(),
)
    .configureServices((context, services) {
  services.addSingleton<CounterManager>(
      implementationFactory: (_) => CounterManager());
}).build();

Future<void> main() async => await host.run();

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counter = host.services.getRequiredService<CounterManager>().counter;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (BuildContext context, int value, Widget? child) => Text(
                '${counter.value}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counter.value++,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
