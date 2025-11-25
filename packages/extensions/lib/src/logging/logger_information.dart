import '../system/disposable.dart';

import 'external_scope_provider.dart';
import 'log_level.dart';
import 'logger.dart';
import 'logger_provider.dart';
import 'support_external_scope.dart';

typedef MessageLoggerFilter = bool Function(
  String provider,
  String category,
  LogLevel? level,
);

class MessageLogger {
  final Logger _logger;
  final String _category;
  final String _providerTypeFullName;
  final LogLevel? _minLevel;
  final MessageLoggerFilter? _filter;

  MessageLogger(
    Logger logger,
    String category,
    String providerTypeFullName,
    LogLevel? minLevel,
    MessageLoggerFilter? filter,
  )   : _logger = logger,
        _category = category,
        _providerTypeFullName = providerTypeFullName,
        _minLevel = minLevel,
        _filter = filter;

  Logger get logger => _logger;

  String get category => _category;

  String get providerTypeFullName => _providerTypeFullName;

  LogLevel? get minLeveL => _minLevel;

  MessageLoggerFilter? get filter => _filter;

  bool isEnabled(LogLevel level) {
    if ((_minLevel != null) && (level.index < _minLevel.index)) {
      return false;
    }

    if (_filter != null) {
      return _filter(_providerTypeFullName, _category, level);
    }

    return true;
  }
}

class ScopeLogger {
  final Logger? _logger;
  final ExternalScopeProvider? _externalScopeProvider;

  ScopeLogger(
    Logger? logger,
    ExternalScopeProvider? externalScopeProvider,
  )   : _logger = logger,
        _externalScopeProvider = externalScopeProvider;

  Logger? get logger => _logger;

  ExternalScopeProvider? get externalScopeProvider => _externalScopeProvider;

  Disposable? createScope<TState>(TState state) {
    if (_externalScopeProvider != null) {
      return _externalScopeProvider.push(state);
    }
    return logger?.beginScope<TState>(state);
  }
}

class LoggerInformation {
  late Type _providerType;
  final Logger _logger;
  final String _category;
  final bool _externalScope;

  LoggerInformation(
    LoggerProvider provider,
    String category,
  )   : _logger = provider.createLogger(category),
        _category = category,
        _externalScope = provider is SupportExternalScope {
    _providerType = provider.runtimeType;
  }

  Logger get logger => _logger;

  String get category => _category;

  Type get providerType => _providerType;

  bool get externalScope => _externalScope;
}
