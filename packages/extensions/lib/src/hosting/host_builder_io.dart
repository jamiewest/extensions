import '../../dependency_injection.dart';
import '../logging/logger_factory.dart';
import '../options/options.dart';
import '../options/options_service_collection_extensions.dart';
import 'host_application_lifetime.dart';
import 'host_environment.dart';
import 'host_lifetime.dart';
import 'host_options.dart';
import 'internal/console_lifetime.dart';
import 'internal/console_lifetime_options.dart';

void addLifetime(ServiceCollection services) => services
  ..configure<ConsoleLifetimeOptions>(
    ConsoleLifetimeOptions.new,
    (options) => options.suppressStatusMessages = false,
  )
  ..addSingleton<HostLifetime>(
    (sp) => ConsoleLifetime(
      sp.getRequiredService<Options<ConsoleLifetimeOptions>>(),
      sp.getRequiredService<HostEnvironment>(),
      sp.getRequiredService<HostApplicationLifetime>(),
      sp.getRequiredService<Options<HostOptions>>(),
      sp.getRequiredService<LoggerFactory>(),
    ),
  );
