import '../../chat_completion/chat_response.dart';

/// A key-value cache for [ChatResponse]s used during evaluation.
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
