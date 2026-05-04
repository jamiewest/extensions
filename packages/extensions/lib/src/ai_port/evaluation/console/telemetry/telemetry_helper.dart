import 'device_id_helper.dart';
import 'environment_helper.dart';
import 'telemetry_constants.dart';

class TelemetryHelper implements AsyncDisposable {
  TelemetryHelper(Logger logger) : _logger = logger {
    if (!TelemetryConstants.isTelemetryEnabled) {
      disabled = true;
      return;
    }
    try {
      _telemetryConfiguration = TelemetryConfiguration.createDefault();
      _telemetryConfiguration.connectionString = TelemetryConstants.connectionString;
      _telemetryClient = telemetryClient(_telemetryConfiguration);
      var deviceIdHelper = deviceIdHelper(logger);
      var deviceId = deviceIdHelper.getDeviceId();
      var isCIEnvironment = EnvironmentHelper.isCIEnvironment().toTelemetryPropertyValue();
      _commonProperties =
                new Dictionary<String, String>
                {
                    [TelemetryConstants.propertyNames.devDeviceId] = deviceId,
                    [TelemetryConstants.propertyNames.osVersion] = Environment.osVersion.versionString,
                    [TelemetryConstants.propertyNames.osPlatform] = Environment.osVersion.platform.toString(),
                    [TelemetryConstants.propertyNames.kernelVersion] = RuntimeInformation.osDescription,
                    [TelemetryConstants.propertyNames.runtimeId] = RuntimeInformation.runtimeIdentifier,
                    [TelemetryConstants.propertyNames.productVersion] = Constants.version,
                    [TelemetryConstants.propertyNames.isCIEnvironment] = isCIEnvironment
                };
      _telemetryClient.context.session.id = Guid.newGuid().toString();
      _telemetryClient.context.device.operatingSystem = RuntimeInformation.osDescription;
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          _logger.logWarning(ex, 'Failed to initialize ${nameof(TelemetryHelper)}.');
          _telemetryConfiguration?.dispose();
          _telemetryConfiguration = null;
          _telemetryClient = null;
          _commonProperties = null;
          disabled = true;
        }
      } else {
        rethrow;
      }
    }
  }

  final Logger _logger;

  final TelemetryConfiguration? _telemetryConfiguration;

  final TelemetryClient? _telemetryClient;

  final Map<String, String>? _commonProperties;

  bool _disposed;

  final bool disabled;

  @override
  Future dispose() async  {
    if (disabled || _disposed) {
      return;
    }
    try {
      _ = await flushAsync().configureAwait(false);
      _telemetryConfiguration.dispose();
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          _logger.logWarning(ex, 'Failed to dispose ${nameof(TelemetryHelper)}.');
        }
      } else {
        rethrow;
      }
    }
    _disposed = true;
  }

  void reportEvent(
    String eventName,
    {Map<String, String>? properties, Map<String, double>? metrics, },
  ) {
    if (disabled || _disposed) {
      return;
    }
    try {
      var combinedProperties = getCombinedProperties(properties);
      _telemetryClient.trackEvent(
                '${TelemetryConstants.eventNamespace}/${eventName}',
                combinedProperties,
                metrics);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          _logger.logWarning(ex, "Failed to report event '{EventName}' in telemetry.", eventName);
        }
      } else {
        rethrow;
      }
    }
  }

  void reportException(
    Exception exception,
    {Map<String, String>? properties, Map<String, double>? metrics, },
  ) {
    if (disabled || _disposed) {
      return;
    }
    try {
      var combinedProperties = getCombinedProperties(properties);
      _telemetryClient.trackException(exception, combinedProperties, metrics);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          _logger.logWarning(ex, 'Failed to report exception in telemetry.');
        }
      } else {
        rethrow;
      }
    }
  }

  Future<bool> flush({CancellationToken? cancellationToken}) async  {
    if (disabled || _disposed) {
      return false;
    }
    try {
      return await _telemetryClient.flushAsync(cancellationToken).configureAwait(false);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          _logger.logWarning(ex, "Failed to flush telemetry.");
          return false;
        }
      } else {
        rethrow;
      }
    }
  }

  Map<String, String>? getCombinedProperties(Map<String, String>? properties) {
    if (disabled || _disposed) {
      return null;
    }
    Map<String, String> combinedProperties;
    if (properties == null) {
      combinedProperties = _commonProperties;
    } else {
      combinedProperties = new Dictionary<String, String>(_commonProperties);
      for (final kvp in properties) {
        combinedProperties.add(kvp.key, kvp.value);
      }
    }
    return combinedProperties;
  }
}
