import 'package:extensions/annotations.dart';

import 'lifetime_tracking_http_message_handler.dart';

/// Tracks an active message handler and its expiration for a named
/// client.
///
/// Upstream also carries a timer and lock per entry; the Dart port
/// checks expiry lazily at `createClient` time and defers disposal to
/// the factory's cleanup cycle, so this entry only carries state.
///
/// Not exported from the `http` barrel; this mirrors the C# `internal`
/// type.
@Source(
  name: 'ActiveHandlerTrackingEntry.cs',
  namespace: 'Microsoft.Extensions.Http',
  repository: 'dotnet/runtime',
  path: 'src/libraries/Microsoft.Extensions.Http/src/',
)
class ActiveHandlerTrackingEntry {
  /// Creates a new [ActiveHandlerTrackingEntry].
  ActiveHandlerTrackingEntry({
    required this.name,
    required this.handler,
    this.expiration,
  });

  /// The logical client name this handler serves.
  final String name;

  /// The tracked handler pipeline.
  final LifetimeTrackingHttpMessageHandler handler;

  /// When the handler expires, or `null` for no expiration.
  final DateTime? expiration;

  /// Whether the handler has expired as of [now].
  bool isExpired(DateTime now) {
    final expiration = this.expiration;
    return expiration != null && expiration.isBefore(now);
  }
}
