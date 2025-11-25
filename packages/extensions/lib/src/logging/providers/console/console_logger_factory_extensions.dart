import '../../../../dependency_injection.dart';
import '../../logger_factory.dart';
import '../../logger_provider.dart';
import '../../logging_builder.dart';
import 'console_logger_provider.dart';

/// Extension methods for the [LoggerFactory] class.
extension ConsoleLoggerFactoryExtensions on LoggingBuilder {
  LoggingBuilder addConsole() {
    services.tryAddIterable(
      ServiceDescriptor.singleton<LoggerProvider>(
        (sp) => ConsoleLoggerProvider(),
      ),
    );
    return this;
  }
}
