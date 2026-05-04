import '../abstractions/realtime/realtime_client.dart';
import 'realtime_client_builder.dart';

/// Provides extension methods for working with [RealtimeClient] in the
/// context of [RealtimeClientBuilder].
extension RealtimeClientBuilderRealtimeClientExtensions on RealtimeClient {
  /// Creates a new [RealtimeClientBuilder] using `innerClient` as its inner
  /// client.
  ///
  /// Remarks: This method is equivalent to using the [RealtimeClientBuilder]
  /// constructor directly, specifying `innerClient` as the inner client.
  ///
  /// Returns: The new [RealtimeClientBuilder] instance.
  ///
  /// [innerClient] The client to use as the inner client.
  RealtimeClientBuilder asBuilder() {
    _ = Throw.ifNull(innerClient);
    return realtimeClientBuilder(innerClient);
  }
}
