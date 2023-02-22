import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';

/// Convenience methods for [ServiceProvider].
extension ServiceProviderExtensions on ServiceProvider {
  /// Creates a [Logger] with the specified [categoryName].
  Logger createLogger(String categoryName) =>
      getRequiredService<LoggerFactory>().createLogger(categoryName);
}
