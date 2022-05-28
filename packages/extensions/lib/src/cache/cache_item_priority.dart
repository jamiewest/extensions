/// Specifies how items are prioritized for preservation during a memory
/// pressure triggered cleanup.
enum CacheItemPriority {
  low,
  normal,
  high,
  neverRemove,
}
