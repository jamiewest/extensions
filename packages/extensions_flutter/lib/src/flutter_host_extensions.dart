import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';

import 'flutter_application_lifetime.dart';

/// Adds convenience menthods to the [Host].
extension FlutterHostExtensions on Host {
  /// The [Configuration] containing the merged configuration
  /// of the application and the [Host].
  Configuration get configuration =>
      services.getRequiredService<Configuration>();

  /// The [HostEnvironment] initialized by the [Host].
  HostEnvironment get environment =>
      services.getRequiredService<HostEnvironment>();

  /// The [HostApplicationLifetime] initialized by the [Host].
  FlutterApplicationLifetime get lifetime =>
      services.getRequiredService<HostApplicationLifetime>()
          as FlutterApplicationLifetime;
}
