import 'package:flutter/material.dart';
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hostProvider = Provider(
  (_) => Host.createDefaultBuilder()
      .configureAppConfiguration((context, configuration) {
        configuration.addInMemoryCollection(
          <String, String>{'test': 'value'}.entries,
        );
      })
      .useFlutterLifetime(
          const ProviderScope(child: MyApp()), FlutterLifetimeOptions())
      .build(),
);

Future<void> main() async {
  final hostContainer = ProviderContainer();
  await hostContainer.read(hostProvider).run();
}

class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(hostProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        logger: host.services
            .getRequiredService<LoggerFactory>()
            .createLogger('test'),
        config: host.services.getRequiredService<Configuration>(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    required this.logger,
    required this.config,
  }) : super(key: key);
  final String title;

  final Logger logger;

  final Configuration config;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    widget.logger.logInformation('ahahaha ${_counter.toString()}');
    widget.logger.logCritical(widget.config['test']);
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
