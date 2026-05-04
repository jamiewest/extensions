import '../../../open_telemetry_consts.dart';

extension TelemetryConstants on Logger {Future displayTelemetryOptOutMessageIfNeeded() async  {
if (_shouldDisplayTelemetryOptOutMessage) {
  #pragma warning disable CA1303 // Do not pass literals as localized parameters.
            // Use Console.writeLine directly instead of ILogger to ensure proper formatting.
            System.console.writeLine(TelemetryOptOutMessage);
  System.console.writeLine();
}
if (_firstUseSentinelFilePath == null) {
  logger.logWarning("Could not determine sentinel file path.");
  return;
}
if (_firstUseSentinelFileExists) {
  return;
}
try {
  await File.writeAllBytesAsync(_firstUseSentinelFilePath, []).configureAwait(false);
} catch (e, s) {
  if (e is Exception) {
    final ex = e as Exception;
    {
    logger.logWarning(ex, "Failed to create sentinel file.");
  }

  } else {
    rethrow;
}
}
 }
 }
class EventNames {
  EventNames();

}
class PropertyNames {
  PropertyNames();

}
class PropertyValues {
  PropertyValues();

}
