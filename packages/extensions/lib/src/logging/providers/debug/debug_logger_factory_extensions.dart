import '../../../../dependency_injection.dart';
import '../../logger_factory.dart';
import '../../logger_provider.dart';
import '../../logging_builder.dart';
import 'debug_logger_provider.dart';

/// Extension methods for the [LoggerFactory] class.
extension DebugLoggerFactoryExtensions on LoggingBuilder {
  LoggingBuilder addDebug() {
    services.tryAddIterable(
      ServiceDescriptor.singleton<LoggerProvider>(
        implementationType:
            // This should not have to be here,
            //it should be reasoned from the factory
            DebugLoggerProvider,
        implementationFactory: (sp) => DebugLoggerProvider(),
      ),
    );
    return this;
  }
}
