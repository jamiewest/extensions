import '../configuration/configuration_manager.dart';
import 'host.dart';
import 'host_application_builder.dart';

/// Settings for constructing an [HostApplicationBuilder].
class HostApplicationBuilderSettings {
  /// Initializes an instance of the [HostApplicationBuilderSettings] class.
  HostApplicationBuilderSettings({
    this.applicationName,
    this.args,
    this.configuration,
    this.configurationRootPath,
    this.disableDefaults = false,
    this.environmentName,
  });

  /// If 'false', configures the [HostApplicationBuilder] instance with
  /// pre-configured defaults. This has a similar effect to calling
  /// [HostingHostBuilderExtensions.configureDefaults()].
  bool disableDefaults;

  /// The command line arguments. This is unused if [disableDefaults] is 'true'.
  List<String>? args;

  /// Initial configuration sources to be added to the
  /// [HostApplicationBuilder.configuration]. These sources can influence
  /// the [HostApplicationBuilder.environment] through the use of 'HostDefaults'
  /// keys. Disposing the built [Host] disposes the [ConfigurationManager].
  ConfigurationManager? configuration;

  /// The environment name.
  String? environmentName;

  /// The application name.
  String? applicationName;

  /// The content root path.
  String? configurationRootPath;
}
