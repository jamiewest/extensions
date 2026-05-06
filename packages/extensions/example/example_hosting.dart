import 'package:extensions/hosting.dart';

/// Demonstrates creating, starting, and stopping a host.
///
/// Run this file to keep the host alive briefly before a graceful shutdown.
void main() {
  print('=== Hosting Example ===');

  final hostBuilder = Host.createApplicationBuilder();
  // ..logging.addDebug()
  // ..logging.setMinimumLevel(LogLevel.trace);

  print('--- Start Host ---');
  final host = hostBuilder.build()..start();

  // Delay stop so you can observe host lifetime behavior.
  Future.delayed(const Duration(seconds: 5), () {
    print('--- Stop Host ---');
    host.stop();
  });
}
