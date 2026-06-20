import 'realtime_client.dart';
import 'realtime_client_builder.dart';

/// Extension methods for creating a [RealtimeClientBuilder] from a
/// [RealtimeClient].
///
/// This is an experimental feature.
extension RealtimeClientBuilderRealtimeClientExtensions on RealtimeClient {
  /// Creates a new [RealtimeClientBuilder] using this client as the innermost
  /// client in the pipeline.
  RealtimeClientBuilder asBuilder() => RealtimeClientBuilder(this);
}
