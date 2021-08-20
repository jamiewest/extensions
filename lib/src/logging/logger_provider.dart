import '../shared/disposable.dart';

import 'logger.dart';

/// Represents a type that can create instances of [Logger].
abstract class LoggerProvider extends Disposable {
  /// Creates a new [Logger] instance.
  Logger createLogger(String categoryName);
}
