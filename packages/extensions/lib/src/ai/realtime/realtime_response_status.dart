import 'package:extensions/annotations.dart';

/// Provides the well-known status values for a real-time response.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeResponseStatus.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
abstract final class RealtimeResponseStatus {
  /// The response completed successfully.
  static const String completed = 'completed';

  /// The response was cancelled.
  static const String cancelled = 'cancelled';

  /// The response is incomplete.
  static const String incomplete = 'incomplete';

  /// The response failed.
  static const String failed = 'failed';
}
