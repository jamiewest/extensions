import 'package:extensions/hosting.dart';

import 'flutter_application_lifetime.dart';

extension FlutterHostExtensions on Host {
  Configuration get configuration =>
      services.getRequiredService<Configuration>();

  HostEnvironment get environment =>
      services.getRequiredService<HostEnvironment>();

  FlutterApplicationLifetime get lifetime =>
      services.getRequiredService<HostApplicationLifetime>()
          as FlutterApplicationLifetime;
}
