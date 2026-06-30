import '../configuration/configuration_builder.dart';
import '../configuration/configuration_manager.dart';
import '../configuration/providers/command_line/command_line_configuration_extensions.dart';
import '../configuration/providers/environment_variables/environment_variables_extensions.dart';
import '../configuration/providers/file_extensions/file_configuration_extensions.dart';
import '../configuration/providers/json/json_configuration_extensions.dart';
import 'host_builder_context.dart';

/// Applies the IO default host configuration: `DOTNET_`-prefixed environment
/// variables.
void applyDefaultHostConfiguration(ConfigurationManager configuration) {
  configuration.addEnvironmentVariables(prefix: 'DOTNET_');
}

/// Applies the IO default app configuration: `appsettings.json`, environment
/// variables, and command-line arguments.
void applyDefaultAppConfiguration(
  HostBuilderContext hostingContext,
  ConfigurationBuilder appConfigBuilder,
  List<String>? args,
) {
  final env = hostingContext.hostingEnvironment!;
  final reloadOnChangeConfig =
      hostingContext.configuration!['hostBuilder:reloadConfigOnChange'];
  final reloadOnChange = reloadOnChangeConfig == 'true';

  appConfigBuilder
    ..setBasePath(env.contentRootPath)
    ..addJson(
      'appsettings.json',
      optional: true,
      reloadOnChange: reloadOnChange,
    )
    ..addJson(
      'appsettings.${env.environmentName}.json',
      optional: true,
      reloadOnChange: reloadOnChange,
    )
    ..addEnvironmentVariables();

  if (args != null && args.isNotEmpty) {
    appConfigBuilder.addCommandLine(args);
  }
}
