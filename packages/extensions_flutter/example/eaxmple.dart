import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/material.dart';

final _builder = Host.createApplicationBuilder()
  ..environment.applicationName = 'extensions_flutter_example'
  ..services.addFlutter(
    (flutter) => flutter.useApp((services) => MyApp(services: services)),
  );

final host = _builder.build();

Future<void> main() async => await host.run();

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.services});

  final ServiceProvider services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Extensions Flutter Example')),
        body: Center(
          child: Text(
            'Hello, ${services.getRequiredService<HostEnvironment>().applicationName}!',
          ),
        ),
      ),
    );
  }
}
