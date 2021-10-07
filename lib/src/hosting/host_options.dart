import '../configuration/configuration.dart';

/// Options for `Host`.
class HostOptions {
  /// The default timeout for `Host.Stop(cancellationToken)`.
  Duration shutdownTimeout = const Duration(seconds: 5);

  // TODO: This needs to be visible from within this library only.
  void initialize(Configuration configuration) {
    var timeoutSeconds = configuration['shutdownTimeoutSeconds'];
    if (timeoutSeconds != null) {
      if (timeoutSeconds.isNotEmpty) {
        shutdownTimeout = Duration(
            seconds: int.parse(timeoutSeconds)); // TODO: Should be tryParse.
      }
    }
  }
}
