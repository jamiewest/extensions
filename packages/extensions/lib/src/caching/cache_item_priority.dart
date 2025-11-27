/// Specifies how items are prioritized for preservation during
/// a memory pressure triggered cleanup.
enum CacheItemPriority {
  /// Items with this priority will be removed as soon as possible during
  /// memory pressure cleanup.
  low,

  /// Items with this priority will be removed after [low] priority items
  /// during memory pressure cleanup.
  normal,

  /// Items with this priority will be removed after [low] and [normal]
  /// priority items during memory pressure cleanup.
  high,

  /// Items with this priority will never be removed during memory pressure
  /// cleanup.
  neverRemove,
}
