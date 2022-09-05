import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:extensions_flutter_plugins/src/plugins/connectivity.dart';

extension HostBuilderExtensions on FlutterBuilder {
  void addConnectivity() {
    services
      ..addSingleton<ConnectivityService>(
        (services) => ConnectivityService(
          logger: services
              .getRequiredService<LoggerFactory>()
              .createLogger('Connectivity'),
        ),
      )
      ..addHostedService<ConnectivityService>(
        (services) => services.getRequiredService<ConnectivityService>(),
      );
  }
}
