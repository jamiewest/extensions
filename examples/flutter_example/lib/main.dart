import 'package:flutter/material.dart';
import 'package:extensions_flutter/extensions_flutter.dart';

class CounterManager {
  CounterManager() : counter = ValueNotifier(0);
  ValueNotifier<int> counter;
}

final app = FlutterApp.create(
  app: const MyApp(),
  enableVersionTracking: true,
  services: (services) => services.addSingleton<CounterManager>(
    (services) => CounterManager(),
  ),
);

// final app = (FlutterApplication.createBuilder()
//       ..logging.addDebug()
//       ..flutter.runApp(const MyApp()))
//     .build();

// final host = (Host.createApplicationBuilder()
//       ..logging.setMinimumLevel(LogLevel.debug)
//       ..services.addFlutter((flutter) => flutter.runApp(const MyApp()))
//       ..services.addSingletonInstance<CounterManager>(CounterManager()))
//     .build();

Future<void> main() async => await app.run();

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
    environment = app.services.getRequiredService<HostingEnvironment>()
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
    final counter = app.services.getRequiredService<CounterManager>().counter;
    final i = app.services.getRequiredService<VersionInfo>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (BuildContext context, int value, Widget? child) => Text(
                '${counter.value} ${i.previousVersion}',
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
