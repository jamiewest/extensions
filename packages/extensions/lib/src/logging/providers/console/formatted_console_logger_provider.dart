import '../../../system/disposable.dart';
import '../../external_scope_provider.dart';
import '../../logger.dart';
import '../../logger_provider.dart';
import '../../null_scope.dart';
import '../../support_external_scope.dart';
import 'console_formatter.dart';
import 'formatted_console_logger.dart';

/// Provider for [FormattedConsoleLogger] instances.
class FormattedConsoleLoggerProvider
    implements LoggerProvider, SupportExternalScope {
  /// Creates a new instance of [FormattedConsoleLoggerProvider].
  FormattedConsoleLoggerProvider(this._formatter);

  final ConsoleFormatter _formatter;
  ExternalScopeProvider? _scopeProvider;

  @override
  Logger createLogger(String categoryName) => FormattedConsoleLogger(
        categoryName,
        _formatter,
        _scopeProvider,
      );

  @override
  Disposable setScopeProvider(ExternalScopeProvider scopeProvider) {
    _scopeProvider = scopeProvider;
    return NullScope.instance;
  }

  @override
  void dispose() {
    // No resources to dispose
  }
}
