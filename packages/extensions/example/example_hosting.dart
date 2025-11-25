import 'package:extensions/hosting.dart';

void main() {
  var builder = Host.createApplicationBuilder();
  // ..logging.addDebug()
  // ..logging.setMinimumLevel(LogLevel.trace);

  var host = builder.build()..start();

  Future.delayed(const Duration(seconds: 5), () => host.stop());
}
