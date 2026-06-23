import 'package:extensions/extensions.dart';

/// Configures a [FunctionInvokingRealtimeClient] instance.
typedef ConfigureFunctionInvokingRealtimeClient = void Function(
  FunctionInvokingRealtimeClient client,
);

/// Provides extensions for adding automatic function invocation to a real-time
/// client pipeline.
///
/// This is an experimental feature.
extension FunctionInvokingRealtimeClientBuilderExtensions
    on RealtimeClientBuilder {
  /// Enables automatic function-call invocation on the real-time pipeline.
  ///
  /// When [loggerFactory] is not supplied, it is resolved from the active
  /// [ServiceProvider] if one is available. [configure] can be used to adjust
  /// the [FunctionInvokingRealtimeClient] before it is added.
  RealtimeClientBuilder useFunctionInvocation({
    LoggerFactory? loggerFactory,
    ConfigureFunctionInvokingRealtimeClient? configure,
  }) {
    return useWithServices((innerClient, services) {
      final factory = loggerFactory ?? services.getService<LoggerFactory>();
      final client = FunctionInvokingRealtimeClient(
        innerClient,
        logger: factory?.createLogger('FunctionInvokingRealtimeClient'),
      );
      configure?.call(client);
      return client;
    });
  }
}
