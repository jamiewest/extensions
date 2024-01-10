import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';

LoggerFactory create(void Function(LoggingBuilder builder) configure) =>
    ServiceCollection()
        .addLogging(configure)
        .buildServiceProvider()
        .getRequiredService<LoggerFactory>();
