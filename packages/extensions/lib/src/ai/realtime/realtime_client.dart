import 'package:extensions/annotations.dart';

import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import 'realtime_client_session.dart';
import 'realtime_session_options.dart';

/// Represents a real-time client.
///
/// Provides methods to create and manage real-time sessions.
///
/// This is an experimental feature.
@Source(
  name: 'IRealtimeClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
abstract class RealtimeClient implements Disposable {
  /// Creates a new real-time session with the specified [options].
  Future<RealtimeClientSession> createSession({
    RealtimeSessionOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Asks the client for an object of the specified type [T].
  ///
  /// Returns the found object, or `null` if no matching service is available.
  T? getService<T>({Object? key});
}
