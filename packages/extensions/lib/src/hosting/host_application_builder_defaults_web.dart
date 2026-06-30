import '../configuration/configuration_builder.dart';
import '../configuration/configuration_manager.dart';
import '../configuration/providers/command_line/command_line_configuration_extensions.dart';
import 'host_builder_context.dart';

/// Applies the web default host configuration.
///
/// There is no process environment on web, so no environment variables are
/// loaded.
void applyDefaultHostConfiguration(ConfigurationManager configuration) {}

/// Applies the web default app configuration.
///
/// File-backed configuration and environment variables are unavailable on web,
/// so only command-line arguments are applied when provided.
void applyDefaultAppConfiguration(
  HostBuilderContext hostingContext,
  ConfigurationBuilder appConfigBuilder,
  List<String>? args,
) {
  if (args != null && args.isNotEmpty) {
    appConfigBuilder.addCommandLine(args);
  }
}
