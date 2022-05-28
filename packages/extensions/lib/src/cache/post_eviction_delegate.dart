import 'eviction_reason.dart';

/// Signature of the callback which gets called when a cache entry expires.
typedef PostEvictionDelegate = void Function(
  Object key,
  Object value,
  EvictionReason reason,
  Object state,
);
