import 'package:flutter/material.dart';
import 'package:extensions_flutter/extensions_flutter.dart';

class CounterManager {
  CounterManager() : counter = ValueNotifier(0);
  ValueNotifier<int> counter;
}

final host = (Host.createApplicationBuilder()
      ..logging.setMinimumLevel(LogLevel.debug)
      ..services.addFlutter((flutter) => flutter.useApp(const MyApp()))
      ..services.addSingletonInstance<CounterManager>(CounterManager()))
    .build();

Future<void> main() async => await host.run();

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterHostingEnvironment? environment;

  @override
  void initState() {
    environment = host.services.getRequiredService<HostingEnvironment>()
        as FlutterHostingEnvironment;
    super.initState();
  }

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
