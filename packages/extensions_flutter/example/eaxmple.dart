import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/material.dart';

final _builder = Host.createApplicationBuilder()
  ..services.addFlutter(
    (flutter) => flutter.useApp((services) => const MyApp()),
  );

final host = _builder.build();

Future<void> main() async => await host.run();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Extensions Flutter Example')),
        body: const Center(child: Text('Hello, Extensions Flutter!')),
      ),
    );
  }
}
