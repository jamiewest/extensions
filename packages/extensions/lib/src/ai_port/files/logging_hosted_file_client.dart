import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/files/delegating_hosted_file_client.dart';
import '../abstractions/files/hosted_file_client.dart';
import '../abstractions/files/hosted_file_client_metadata.dart';
import '../abstractions/files/hosted_file_client_options.dart';
import '../abstractions/files/hosted_file_download_stream.dart';
import '../telemetry_helpers.dart';

/// A delegating hosted file client that logs file operations to an [Logger].
///
/// Remarks: The provided implementation of [HostedFileClient] is thread-safe
/// for concurrent use so long as the [Logger] employed is also thread-safe
/// for concurrent use. When the employed [Logger] enables [Trace], the
/// contents of options and results are logged. These may contain sensitive
/// application data. [Trace] is disabled by default and should never be
/// enabled in a production environment. Options and results are not logged at
/// other logging levels.
class LoggingHostedFileClient extends DelegatingHostedFileClient {
  /// Initializes a new instance of the [LoggingHostedFileClient] class.
  ///
  /// [innerClient] The underlying [HostedFileClient].
  ///
  /// [logger] An [Logger] instance that will be used for all logging.
  LoggingHostedFileClient(
    HostedFileClient innerClient,
    Logger logger,
  ) :
      _logger = Throw.ifNull(logger),
      _jsonSerializerOptions = AIJsonUtilities.defaultOptions;

  /// An [Logger] instance used for all logging.
  final Logger _logger;

  /// The [JsonSerializerOptions] to use for serialization of state written to
  /// the logger.
  JsonSerializerOptions _jsonSerializerOptions;

  /// Gets or sets JSON serialization options to use when serializing logging
  /// data.
  JsonSerializerOptions jsonSerializerOptions;

  @override
  Future<HostedFileContent> upload(
    Stream content,
    {String? mediaType, String? fileName, HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    fileName ??= content is FileStream fs ? Path.getFileName(fs.name) : null;
    mediaType ??= fileName != null ? MediaTypeMap.getMediaType(fileName) : null;
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logUploadInvokedSensitive(
          mediaType,
          fileName,
          asJson(options),
          asJson(this.getService<HostedFileClientMetadata>()),
        );
      } else {
        logInvoked(nameof(UploadAsync));
      }
    }
    try {
      var result = await base.uploadAsync(
        content,
        mediaType,
        fileName,
        options,
        cancellationToken,
      ) .configureAwait(false);
      if (_logger.isEnabled(LogLevel.debug)) {
        if (_logger.isEnabled(LogLevel.trace)) {
          logCompletedSensitive(nameof(UploadAsync), asJson(result));
        } else {
          logCompleted(nameof(UploadAsync));
        }
      }
      return result;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(UploadAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(UploadAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<HostedFileDownloadStream> download(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logDownloadInvokedSensitive(
          fileId,
          asJson(options),
          asJson(this.getService<HostedFileClientMetadata>()),
        );
      } else {
        logInvoked(nameof(DownloadAsync));
      }
    }
    try {
      var result = await base.downloadAsync(
        fileId,
        options,
        cancellationToken,
      ) .configureAwait(false);
      logCompleted(nameof(DownloadAsync));
      return result;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(DownloadAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(DownloadAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<HostedFileContent?> getFileInfo(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logGetFileInfoInvokedSensitive(
          fileId,
          asJson(options),
          asJson(this.getService<HostedFileClientMetadata>()),
        );
      } else {
        logInvoked(nameof(GetFileInfoAsync));
      }
    }
    try {
      var result = await base.getFileInfoAsync(
        fileId,
        options,
        cancellationToken,
      ) .configureAwait(false);
      if (_logger.isEnabled(LogLevel.debug)) {
        if (_logger.isEnabled(LogLevel.trace)) {
          logCompletedSensitive(nameof(GetFileInfoAsync), asJson(result));
        } else {
          logCompleted(nameof(GetFileInfoAsync));
        }
      }
      return result;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(GetFileInfoAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(GetFileInfoAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Stream<HostedFileContent> listFiles({HostedFileClientOptions? options, CancellationToken? cancellationToken, }) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logListFilesInvokedSensitive(
          asJson(options),
          asJson(this.getService<HostedFileClientMetadata>()),
        );
      } else {
        logInvoked(nameof(ListFilesAsync));
      }
    }
    IAsyncEnumerator<HostedFileContent> e;
    try {
      e = base.listFilesAsync(options, cancellationToken).getAsyncEnumerator(cancellationToken);
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(ListFilesAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(ListFilesAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    try {
      var file = null;
      while (true) {
        try {
          if (!await e.moveNextAsync().configureAwait(false)) {
            break;
          }
          file = e.current;
        } catch (e, s) {
          if (e is OperationCanceledException) {
            final  = e as OperationCanceledException;
            {
              logInvocationCanceled(nameof(ListFilesAsync));
              rethrow;
            }
          } else       if (e is Exception) {
            final ex = e as Exception;
            {
              logInvocationFailed(nameof(ListFilesAsync), ex);
              rethrow;
            }
          } else {
            rethrow;
          }
        }
        if (_logger.isEnabled(LogLevel.trace)) {
          logListItemSensitive(asJson(file));
        }
        yield file;
      }
      logCompleted(nameof(ListFilesAsync));
    } finally {
      await e.disposeAsync().configureAwait(false);
    }
  }

  @override
  Future<bool> delete(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (_logger.isEnabled(LogLevel.debug)) {
      if (_logger.isEnabled(LogLevel.trace)) {
        logDeleteInvokedSensitive(
          fileId,
          asJson(options),
          asJson(this.getService<HostedFileClientMetadata>()),
        );
      } else {
        logInvoked(nameof(DeleteAsync));
      }
    }
    try {
      var result = await base.deleteAsync(fileId, options, cancellationToken).configureAwait(false);
      if (_logger.isEnabled(LogLevel.debug)) {
        if (_logger.isEnabled(LogLevel.trace)) {
          logCompletedSensitive(nameof(DeleteAsync), asJson(result));
        } else {
          logCompleted(nameof(DeleteAsync));
        }
      }
      return result;
    } catch (e, s) {
      if (e is OperationCanceledException) {
        final  = e as OperationCanceledException;
        {
          logInvocationCanceled(nameof(DeleteAsync));
          rethrow;
        }
      } else   if (e is Exception) {
        final ex = e as Exception;
        {
          logInvocationFailed(nameof(DeleteAsync), ex);
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  String asJson<T>(T value) {
    return TelemetryHelpers.asJson(value, _jsonSerializerOptions);
  }

  void logInvoked(String methodName) {
    // TODO: implement LogInvoked
    // C#:
    throw UnimplementedError('LogInvoked not implemented');
  }

  void logUploadInvokedSensitive(
    String? mediaType,
    String? fileName,
    String hostedFileOptions,
    String hostedFileClientMetadata,
  ) {
    // TODO: implement LogUploadInvokedSensitive
    // C#:
    throw UnimplementedError('LogUploadInvokedSensitive not implemented');
  }

  void logDownloadInvokedSensitive(
    String fileId,
    String hostedFileOptions,
    String hostedFileClientMetadata,
  ) {
    // TODO: implement LogDownloadInvokedSensitive
    // C#:
    throw UnimplementedError('LogDownloadInvokedSensitive not implemented');
  }

  void logGetFileInfoInvokedSensitive(
    String fileId,
    String hostedFileOptions,
    String hostedFileClientMetadata,
  ) {
    // TODO: implement LogGetFileInfoInvokedSensitive
    // C#:
    throw UnimplementedError('LogGetFileInfoInvokedSensitive not implemented');
  }

  void logListFilesInvokedSensitive(String hostedFileOptions, String hostedFileClientMetadata, ) {
    // TODO: implement LogListFilesInvokedSensitive
    // C#:
    throw UnimplementedError('LogListFilesInvokedSensitive not implemented');
  }

  void logDeleteInvokedSensitive(
    String fileId,
    String hostedFileOptions,
    String hostedFileClientMetadata,
  ) {
    // TODO: implement LogDeleteInvokedSensitive
    // C#:
    throw UnimplementedError('LogDeleteInvokedSensitive not implemented');
  }

  void logCompleted(String methodName) {
    // TODO: implement LogCompleted
    // C#:
    throw UnimplementedError('LogCompleted not implemented');
  }

  void logCompletedSensitive(String methodName, String hostedFileResult, ) {
    // TODO: implement LogCompletedSensitive
    // C#:
    throw UnimplementedError('LogCompletedSensitive not implemented');
  }

  void logListItemSensitive(String hostedFileContent) {
    // TODO: implement LogListItemSensitive
    // C#:
    throw UnimplementedError('LogListItemSensitive not implemented');
  }

  void logInvocationCanceled(String methodName) {
    // TODO: implement LogInvocationCanceled
    // C#:
    throw UnimplementedError('LogInvocationCanceled not implemented');
  }

  void logInvocationFailed(String methodName, Exception error, ) {
    // TODO: implement LogInvocationFailed
    // C#:
    throw UnimplementedError('LogInvocationFailed not implemented');
  }
}
