import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_response.dart';

/// A key-value cache for [ChatResponse]s used during evaluation.
@Source(
  name: 'IDistributedCache.cs',
  namespace: 'Microsoft.Extensions.Caching.Distributed',
  repository: 'dotnet/runtime',
  path: 'src/libraries/Microsoft.Extensions.Caching.Abstractions/',
)
abstract class ResponseCache {
  /// Returns the cached [ChatResponse] for [key], or `null` if not found or
  /// expired.
  Future<ChatResponse?> get(String key);

  /// Stores [response] in the cache under [key].
  Future<void> set(String key, ChatResponse response);

  /// Removes the entry for [key] from the cache.
  Future<void> remove(String key);

  /// Clears all entries from the cache.
  Future<void> reset();

  /// Removes all expired entries from the cache.
  Future<void> deleteExpiredEntries();
}
