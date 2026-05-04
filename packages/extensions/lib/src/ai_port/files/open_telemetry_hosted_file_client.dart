import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/files/delegating_hosted_file_client.dart';
import '../abstractions/files/hosted_file_client.dart';
import '../abstractions/files/hosted_file_client_metadata.dart';
import '../abstractions/files/hosted_file_client_options.dart';
import '../abstractions/files/hosted_file_download_stream.dart';
import '../common/open_telemetry_log.dart';
import '../open_telemetry_consts.dart';

/// Represents a delegating hosted file client that implements
/// OpenTelemetry-compatible tracing and metrics for file operations.
///
/// Remarks: Since there is currently no OpenTelemetry Semantic Convention for
/// hosted file operations, this implementation uses general client span
/// conventions alongside standard `file.*` registry attributes where
/// applicable. The specification is subject to change as relevant
/// OpenTelemetry conventions emerge; as such, the telemetry output by this
/// client is also subject to change.
class OpenTelemetryHostedFileClient extends DelegatingHostedFileClient {
  /// Initializes a new instance of the [OpenTelemetryHostedFileClient] class.
  ///
  /// [innerClient] The underlying [HostedFileClient].
  ///
  /// [logger] The [Logger] to use for emitting any logging data from the
  /// client.
  ///
  /// [sourceName] An optional source name that will be used on the telemetry
  /// data.
  OpenTelemetryHostedFileClient(
    HostedFileClient innerClient,
    {Logger? logger = null, String? sourceName = null, },
  ) :
      _logger = logger,
      _activitySource = new(name),
      _meter = new(name),
      _operationDurationHistogram = _meter.createHistogram<double>(
            OperationDurationMetricName,
            OpenTelemetryConsts.secondsUnit,
            OperationDurationMetricDescription,
            advice: new() { HistogramBucketBoundaries = OpenTelemetryConsts.genAI.client.operationDuration.explicitBucketBoundaries }
            ) {
    Debug.assertValue(innerClient != null, "Should have been validated by the base ctor");
    if (innerClient!.getService<HostedFileClientMetadata>() is HostedFileClientMetadata) {
      final metadata = innerClient!.getService<HostedFileClientMetadata>() as HostedFileClientMetadata;
      _providerName = metadata.providerName;
      _serverAddress = metadata.providerUri?.host;
      _serverPort = metadata.providerUri?.port ?? 0;
    }
    var name = string.isNullOrEmpty(sourceName) ? OpenTelemetryConsts.defaultSourceName : sourceName!;
  }

  final ActivitySource _activitySource;

  final Meter _meter;

  final Histogram<double> _operationDurationHistogram;

  final String? _providerName;

  final String? _serverAddress;

  final int _serverPort;

  final Logger? _logger;

  /// Gets or sets a value indicating whether potentially sensitive information
  /// should be included in telemetry.
  ///
  /// Remarks: By default, telemetry includes operation metadata such as
  /// provider name, duration, file IDs, file sizes, media types, purposes, and
  /// scopes. When enabled, telemetry will additionally include file names,
  /// which may contain sensitive information. The default value can be
  /// overridden by setting the
  /// `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` environment variable
  /// to "true". Explicitly setting this property will override the environment
  /// variable.
  bool enableSensitiveData = TelemetryHelpers.EnableSensitiveDataDefault;

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    return serviceKey == null && serviceType == typeof(ActivitySource) ? _activitySource :
        base.getService(serviceType, serviceKey);
  }

  @override
  void dispose(bool disposing) {
    if (disposing) {
      _activitySource.dispose();
      _meter.dispose();
    }
    base.dispose(disposing);
  }

  @override
  Future<HostedFileContent> upload(
    Stream content,
    {String? mediaType, String? fileName, HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    fileName ??= content is FileStream fs ? Path.getFileName(fs.name) : null;
    mediaType ??= fileName != null ? MediaTypeMap.getMediaType(fileName) : null;
    var activity = startActivity(UploadOperationName);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    if (activity is { IsAllDataRequested: true }) {
      if (mediaType != null) {
        _ = activity.addTag(FilesMediaTypeAttribute, mediaType);
      }
      if (options?.purpose is string) {
        final purpose = options?.purpose as string;
        _ = activity.addTag(FilesPurposeAttribute, purpose);
      }
      if (options?.scope is string) {
        final scope = options?.scope as string;
        _ = activity.addTag(FilesScopeAttribute, scope);
      }
      if (enableSensitiveData && fileName != null) {
        _ = activity.addTag(OpenTelemetryConsts.file.name, fileName);
      }
      tagAdditionalProperties(activity, options);
    }
    var result = null;
    var error = null;
    try {
      result = await base.uploadAsync(
        content,
        mediaType,
        fileName,
        options,
        cancellationToken,
      ) .configureAwait(false);
      return result;
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          error = ex;
          rethrow;
        }
      } else {
        rethrow;
      }
    } finally {
      if (result != null && activity is { IsAllDataRequested: true }) {
        _ = activity.addTag(FilesIdAttribute, result.fileId);
        if (result.sizeInBytes is long) {
          final size = result.sizeInBytes as long;
          _ = activity.addTag(OpenTelemetryConsts.file.size, size);
        }
      }
      recordDuration(stopwatch, UploadOperationName, error);
      setErrorStatus(activity, error);
    }
  }

  @override
  Future<HostedFileDownloadStream> download(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    var activity = startActivity(DownloadOperationName);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    if (activity is { IsAllDataRequested: true }) {
      _ = activity.addTag(FilesIdAttribute, fileId);
      if (options?.scope is string) {
        final scope = options?.scope as string;
        _ = activity.addTag(FilesScopeAttribute, scope);
      }
      tagAdditionalProperties(activity, options);
    }
    var error = null;
    try {
      var result = await base.downloadAsync(
        fileId,
        options,
        cancellationToken,
      ) .configureAwait(false);
      return result;
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          error = ex;
          rethrow;
        }
      } else {
        rethrow;
      }
    } finally {
      recordDuration(stopwatch, DownloadOperationName, error);
      setErrorStatus(activity, error);
    }
  }

  @override
  Future<HostedFileContent?> getFileInfo(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    var activity = startActivity(GetInfoOperationName);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    if (activity is { IsAllDataRequested: true }) {
      _ = activity.addTag(FilesIdAttribute, fileId);
      if (options?.scope is string) {
        final scope = options?.scope as string;
        _ = activity.addTag(FilesScopeAttribute, scope);
      }
      tagAdditionalProperties(activity, options);
    }
    var result = null;
    var error = null;
    try {
      result = await base.getFileInfoAsync(
        fileId,
        options,
        cancellationToken,
      ) .configureAwait(false);
      return result;
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          error = ex;
          rethrow;
        }
      } else {
        rethrow;
      }
    } finally {
      if (result != null && activity is { IsAllDataRequested: true }) {
        if (enableSensitiveData && result.name is string) {
          final name = enableSensitiveData && result.name as string;
          _ = activity.addTag(OpenTelemetryConsts.file.name, name);
        }
        if (result.sizeInBytes is long) {
          final size = result.sizeInBytes as long;
          _ = activity.addTag(OpenTelemetryConsts.file.size, size);
        }
      }
      recordDuration(stopwatch, GetInfoOperationName, error);
      setErrorStatus(activity, error);
    }
  }

  @override
  Stream<HostedFileContent> listFiles({HostedFileClientOptions? options, CancellationToken? cancellationToken, }) async  {
    var activity = startActivity(ListOperationName);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    if (activity is { IsAllDataRequested: true }) {
      if (options?.scope is string) {
        final scope = options?.scope as string;
        _ = activity.addTag(FilesScopeAttribute, scope);
      }
      if (options?.purpose is string) {
        final purpose = options?.purpose as string;
        _ = activity.addTag(FilesPurposeAttribute, purpose);
      }
      tagAdditionalProperties(activity, options);
    }
    IAsyncEnumerator<HostedFileContent> e;
    var error = null;
    try {
      e = base.listFilesAsync(options, cancellationToken).getAsyncEnumerator(cancellationToken);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          error = ex;
          recordDuration(stopwatch, ListOperationName, error);
          setErrorStatus(activity, error);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    var count = 0;
    try {
      while (true) {
        try {
          if (!await e.moveNextAsync().configureAwait(false)) {
            break;
          }
        } catch (e, s) {
          if (e is Exception) {
            final ex = e as Exception;
            {
              error = ex;
              rethrow;
            }
          } else {
            rethrow;
          }
        }
        count++;
        yield e.current;
        if (activity != null) {
          Activity.current = activity;
        }
      }
    } finally {
      if (activity is { IsAllDataRequested: true }) {
        _ = activity.addTag(FilesListCountAttribute, count);
      }
      recordDuration(stopwatch, ListOperationName, error);
      setErrorStatus(activity, error);
      await e.disposeAsync().configureAwait(false);
    }
  }

  @override
  Future<bool> delete(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    var activity = startActivity(DeleteOperationName);
    var stopwatch = _operationDurationHistogram.enabled ? Stopwatch.startNew() : null;
    if (activity is { IsAllDataRequested: true }) {
      _ = activity.addTag(FilesIdAttribute, fileId);
      if (options?.scope is string) {
        final scope = options?.scope as string;
        _ = activity.addTag(FilesScopeAttribute, scope);
      }
      tagAdditionalProperties(activity, options);
    }
    var error = null;
    try {
      return await base.deleteAsync(fileId, options, cancellationToken).configureAwait(false);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          error = ex;
          rethrow;
        }
      } else {
        rethrow;
      }
    } finally {
      recordDuration(stopwatch, DeleteOperationName, error);
      setErrorStatus(activity, error);
    }
  }

  void setErrorStatus(Activity? activity, Exception? error, ) {
    OpenTelemetryLog.recordOperationError(activity, _logger, error);
  }

  void tagAdditionalProperties(Activity activity, HostedFileClientOptions? options, ) {
    if (enableSensitiveData && options?.additionalProperties is { } props) {
      for (final prop in props) {
        _ = activity.addTag(prop.key, prop.value);
      }
    }
  }

  Activity? startActivity(String operationName) {
    var activity = null;
    if (_activitySource.hasListeners()) {
      activity = _activitySource.startActivity(
                operationName,
                ActivityKind.client);
      if (activity is { IsAllDataRequested: true }) {
        _ = activity
                    .addTag(FilesOperationNameAttribute, operationName)
                    .addTag(FilesProviderNameAttribute, _providerName);
        if (_serverAddress != null) {
          _ = activity
                        .addTag(OpenTelemetryConsts.server.address, _serverAddress)
                        .addTag(OpenTelemetryConsts.server.port, _serverPort);
        }
      }
    }
    return activity;
  }

  void recordDuration(Stopwatch? stopwatch, String operationName, Exception? error, ) {
    if (_operationDurationHistogram.enabled && stopwatch != null) {
      var tags = default;
      tags.add(FilesOperationNameAttribute, operationName);
      tags.add(FilesProviderNameAttribute, _providerName);
      if (_serverAddress is string) {
        final address = _serverAddress as string;
        tags.add(OpenTelemetryConsts.server.address, address);
        tags.add(OpenTelemetryConsts.server.port, _serverPort);
      }
      if (error != null) {
        tags.add(OpenTelemetryConsts.error.type, error.getType().fullName);
      }
      _operationDurationHistogram.record(stopwatch.elapsed.totalSeconds, tags);
    }
  }
}
