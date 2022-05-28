enum EvictionReason {
  none,
  removed, // Manually
  replaced, // Overwritten
  expired, // Timed out
  tokenExpired, // Event
  capacity, // Overflow
}
