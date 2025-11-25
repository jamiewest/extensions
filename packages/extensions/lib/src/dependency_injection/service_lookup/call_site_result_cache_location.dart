enum CallSiteResultCacheLocation {
  root(value: 0),
  scope(value: 1),
  dispose(value: 2),
  none(value: 3);

  const CallSiteResultCacheLocation({
    required this.value,
  });

  final int value;
}
