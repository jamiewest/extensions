import '../../utilities/timing_helper.dart';
import 'telemetry_constants.dart';

extension TelemetryExtensions on bool {
  String toTelemetryPropertyValue({String? defaultValue}) {
    return value
        ? TelemetryConstants.propertyValues.trueValue
        : TelemetryConstants.propertyValues.falseValue;
  }

  void reportOperation(
    String operationName,
    Map<String, String>? properties,
    Map<String, double>? metrics,
    Logger? logger, {
    void Function()? operation,
  }) {
    try {
      var duration = TimingHelper.executeWithTiming(operation);
      telemetryHelper.reportOperationSuccess(
        operationName,
        duration,
        properties,
        metrics,
        logger,
      );
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          telemetryHelper.reportOperationFailure(
            operationName,
            ex,
            properties,
            metrics,
            logger,
          );
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  Future reportOperationAsync(
    String operationName,
    Map<String, String>? properties,
    Map<String, double>? metrics,
    Logger? logger, {
    Future Function()? operation,
  }) async {
    try {
      var duration = await TimingHelper.executeWithTimingAsync(
        operation,
      ).configureAwait(false);
      telemetryHelper.reportOperationSuccess(
        operationName,
        duration,
        properties,
        metrics,
        logger,
      );
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          telemetryHelper.reportOperationFailure(
            operationName,
            ex,
            properties,
            metrics,
            logger,
          );
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  void reportOperationSuccess(
    String operationName,
    Duration duration, {
    Map<String, String>? properties,
    Map<String, double>? metrics,
    Logger? logger,
  }) {
    /* TODO: unsupported node kind "unknown" */
    // void Report()
    //         {
    //             string durationInMilliseconds = duration.ToMillisecondsText();
    //
    //             properties ??= new Dictionary<string, string>();
    //             properties.Add(TelemetryConstants.PropertyNames.Success, TelemetryConstants.PropertyValues.True);
    //             properties.Add(TelemetryConstants.PropertyNames.DurationInMilliseconds, durationInMilliseconds);
    //
    //             telemetryHelper.ReportEvent(eventName: operationName, properties, metrics);
    //         }
    if (logger == null) {
      try {
        report();
      } catch (e, s) {
        {}
      }
    } else {
      // Log and ignore exceptions encountered when trying to report telemetry.
      logger.executeWithCatch(Report, swallowUnhandledExceptions: true);
    }
  }

  void reportOperationFailure(
    String operationName,
    Exception exception, {
    Map<String, String>? properties,
    Map<String, double>? metrics,
    Logger? logger,
  }) {
    /* TODO: unsupported node kind "unknown" */
    // void Report()
    //         {
    //             properties ??= new Dictionary<string, string>();
    //             properties.Add(TelemetryConstants.PropertyNames.Success, TelemetryConstants.PropertyValues.False);
    //
    //             telemetryHelper.ReportEvent(eventName: operationName, properties, metrics);
    //             telemetryHelper.ReportException(exception, properties, metrics);
    //         }
    if (logger == null) {
      try {
        report();
      } catch (e, s) {
        {}
      }
    } else {
      // Log and ignore exceptions encountered when trying to report telemetry.
      logger.executeWithCatch(Report, swallowUnhandledExceptions: true);
    }
  }
}
