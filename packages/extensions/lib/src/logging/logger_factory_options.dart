import 'package:extensions/src/logging/activity_tracking_options.dart';

import 'logger_factory.dart';

/// The options for a [LoggerFactory].
class LoggerFactoryOptions {
  /// Creates a new [LoggerFactoryOptions] instance.
  LoggerFactoryOptions();

  /// Gets or sets [LoggerFactoryOptions] value to indicate which parts of the
  /// tracing context information should be included with the logging scopes.
  ActivityTrackingOptions? activityTrackingOptions;
}
