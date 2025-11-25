import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/src/options/options_monitor.dart';
import 'package:extensions/system.dart';

/// Test logger provider that tracks created loggers.
class TestLoggerProvider implements LoggerProvider {
  final List<String> createdLoggers = [];
  final Map<String, TestLogger> loggers = {};
  bool isDisposed = false;

  @override
  Logger createLogger(String categoryName) {
    createdLoggers.add(categoryName);
    final logger = TestLogger(categoryName);
    loggers[categoryName] = logger;
    return logger;
  }

  @override
  void dispose() {
    isDisposed = true;
    loggers.clear();
  }
}

/// Test logger that tracks log calls.
class TestLogger implements Logger {
  TestLogger(this.categoryName);

  final String categoryName;
  final List<LogEntry> loggedMessages = [];
  final List<dynamic> scopes = [];

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    loggedMessages.add(
      LogEntry(
        logLevel: logLevel,
        eventId: eventId,
        message: formatter(state, error),
        error: error,
      ),
    );
  }

  @override
  bool isEnabled(LogLevel logLevel) => true;

  @override
  Disposable? beginScope<TState>(TState state) {
    scopes.add(state);
    return Scope();
  }
}

/// Represents a logged entry.
class LogEntry {
  LogEntry({
    required this.logLevel,
    required this.eventId,
    required this.message,
    this.error,
  });

  final LogLevel logLevel;
  final EventId eventId;
  final String message;
  final Object? error;
}

/// Test logger provider that throws on disposal.
class ThrowingDisposableProvider implements LoggerProvider {
  @override
  Logger createLogger(String categoryName) => TestLogger(categoryName);

  @override
  void dispose() {
    throw Exception('Disposal failed');
  }
}

/// Test options monitor that can trigger changes.
class TestOptionsMonitor implements OptionsMonitor<LoggerFilterOptions> {
  TestOptionsMonitor(this._currentValue);

  LoggerFilterOptions _currentValue;
  final List<OnChangeListener<LoggerFilterOptions>> _listeners = [];

  @override
  LoggerFilterOptions get currentValue => _currentValue;

  @override
  LoggerFilterOptions get(String? name) => _currentValue;

  @override
  Disposable? onChange(OnChangeListener<LoggerFilterOptions> listener) {
    _listeners.add(listener);
    return Scope();
  }

  @override
  void dispose() {
    _listeners.clear();
  }

  void triggerChange(LoggerFilterOptions newValue) {
    _currentValue = newValue;
    for (final listener in _listeners) {
      listener(newValue, null);
    }
  }
}

/// Test logger that can be configured to throw exceptions.
class ThrowingLogger implements Logger {
  ThrowingLogger({
    this.throwOnLog = false,
    this.throwOnIsEnabled = false,
    this.throwOnBeginScope = false,
  });

  final bool throwOnLog;
  final bool throwOnIsEnabled;
  final bool throwOnBeginScope;

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    if (throwOnLog) {
      throw Exception('Log failed');
    }
  }

  @override
  bool isEnabled(LogLevel logLevel) {
    if (throwOnIsEnabled) {
      throw Exception('IsEnabled failed');
    }
    return true;
  }

  @override
  Disposable? beginScope<TState>(TState state) {
    if (throwOnBeginScope) {
      throw Exception('BeginScope failed');
    }
    return Scope();
  }
}

/// Test logger provider that creates throwing loggers.
class ThrowingLoggerProvider implements LoggerProvider {
  ThrowingLoggerProvider({
    this.throwOnLog = false,
    this.throwOnIsEnabled = false,
    this.throwOnBeginScope = false,
  });

  final bool throwOnLog;
  final bool throwOnIsEnabled;
  final bool throwOnBeginScope;

  @override
  Logger createLogger(String categoryName) {
    return ThrowingLogger(
      throwOnLog: throwOnLog,
      throwOnIsEnabled: throwOnIsEnabled,
      throwOnBeginScope: throwOnBeginScope,
    );
  }

  @override
  void dispose() {}
}

/// Test logger that tracks isEnabled calls.
class FilterableLogger implements Logger {
  FilterableLogger(this.categoryName, this.minLevel);

  final String categoryName;
  final LogLevel minLevel;
  final List<LogEntry> loggedMessages = [];

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    if (isEnabled(logLevel)) {
      loggedMessages.add(
        LogEntry(
          logLevel: logLevel,
          eventId: eventId,
          message: formatter(state, error),
          error: error,
        ),
      );
    }
  }

  @override
  bool isEnabled(LogLevel logLevel) => logLevel.value >= minLevel.value;

  @override
  Disposable? beginScope<TState>(TState state) => Scope();
}

/// Test logger provider that creates filterable loggers.
class FilterableLoggerProvider implements LoggerProvider {
  FilterableLoggerProvider([this.minLevel = LogLevel.trace]);

  final LogLevel minLevel;
  final Map<String, FilterableLogger> loggers = {};

  @override
  Logger createLogger(String categoryName) {
    final logger = FilterableLogger(categoryName, minLevel);
    loggers[categoryName] = logger;
    return logger;
  }

  @override
  void dispose() {
    loggers.clear();
  }
}
