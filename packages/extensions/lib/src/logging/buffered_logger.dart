import 'buffered_log_record.dart';

/// Enables logging providers to handle batched log entries.
///
/// When a logging provider implements this interface, the logging
/// infrastructure can detect this capability and will deliver logs in batches,
/// rather than invoking the standard Logger interface one log at a time.
abstract class BufferedLogger {
  /// Delivers a batch of buffered log records to a logging provider.
  ///
  /// Once this function returns, the implementation should no longer access
  /// the records or state referenced by the [records] parameter, as these
  /// instances may be recycled for subsequent logging operations.
  void logRecords(Iterable<BufferedLogRecord> records);
}
