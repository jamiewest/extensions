import '../../../../../lib/func_typedefs.dart';
import 'function_invoking_realtime_client.dart';
import 'realtime_client_builder.dart';

/// Provides extension methods for attaching function invocation middleware to
/// a realtime client pipeline.
extension FunctionInvokingRealtimeClientBuilderExtensions on RealtimeClientBuilder {
  /// Enables automatic function call invocation on the realtime client
/// pipeline.
///
/// Returns: The supplied `builder`.
///
/// [builder] The [RealtimeClientBuilder] being used to build the realtime
/// client pipeline.
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging function invocations.
///
/// [configure] An optional callback that can be used to configure the
/// [FunctionInvokingRealtimeClient] instance.
RealtimeClientBuilder useFunctionInvocation({LoggerFactory? loggerFactory, Action<FunctionInvokingRealtimeClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var client = functionInvokingRealtimeClient(innerClient, loggerFactory, services);
            configure?.invoke(client);
            return client;
        });
 }
 }
