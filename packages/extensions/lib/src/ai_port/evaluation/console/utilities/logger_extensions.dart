extension LoggerExtensions on Logger {
  bool logException(Exception exception) {
    logger.logError(exception, message: null);
    return true;
  }

  void executeWithCatch(
    bool swallowUnhandledExceptions, {
    void Function()? operation,
    TResult? defaultValue,
  }) {
    try {
      operation();
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {}
      } else {
        rethrow;
      }
    }
  }

  Future executeWithCatchAsync(
    bool swallowUnhandledExceptions, {
    Future Function()? operation,
    TResult? defaultValue,
  }) async {
    try {
      await operation().configureAwait(false);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {}
      } else {
        rethrow;
      }
    }
  }
}
