enum CallSiteResultCacheLocation {
  root,
  scope,
  dispose,
  none,
}

extension CallSiteResultCacheLocationExtensions on CallSiteResultCacheLocation {
  int get value {
    switch (this) {
      case CallSiteResultCacheLocation.root:
        return 0;
      case CallSiteResultCacheLocation.scope:
        return 1;
      case CallSiteResultCacheLocation.dispose:
        return 2;
      case CallSiteResultCacheLocation.none:
        return 3;
    }
  }
}
