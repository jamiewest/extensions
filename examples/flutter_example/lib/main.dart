import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter_example/plugins/device_preview.dart';
import 'package:flutter_example/plugins/firebase.dart';

//import 'firebase_options.dart';

final builder = Host.createApplicationBuilder()
  ..services.addSingletonInstance<ValueNotifier<int>>(ValueNotifier(0))
  ..services.addFlutter<MyApp>(const MyApp(), configure: (flutter) => flutter
      // ..useFirebase(
      //   options: DefaultFirebaseOptions.currentPlatform,
      //   configure: (firebase) => firebase
      //     ..addCrashlytics()
      //     ..addAnalytics(),
      //)
      //..useDevicePreview(),
      );

final host = builder.build();

Future<void> main() async => await host.run();

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      builder: DevicePreview.appBuilder,
      home: SafeArea(child: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counter = host.services.getRequiredService<ValueNotifier<int>>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caleb'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (BuildContext context, int value, Widget? child) => Text(
                '${counter.value} ',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            TextButton(
              onPressed: () => throw Exception('Test'),
              child: const Text("Throw Test Exception"),
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
