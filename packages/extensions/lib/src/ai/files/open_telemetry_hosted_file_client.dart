import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../common/telemetry_helpers.dart';
import '../hosted_file_content.dart';
import '../open_telemetry_consts.dart';
import 'delegating_hosted_file_client.dart';
import 'hosted_file_client.dart';

/// A [DelegatingHostedFileClient] that records OpenTelemetry spans.
///
/// This implementation uses `dart:developer` timeline events. To
/// connect it to a real OpenTelemetry SDK, subclass and wrap the file
/// operations.
///
/// This is an experimental feature.
@Source(
  name: 'OpenTelemetryHostedFileClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Files/',
)
class OpenTelemetryHostedFileClient extends DelegatingHostedFileClient {
  /// Creates a new [OpenTelemetryHostedFileClient].
  OpenTelemetryHostedFileClient(
    super.innerClient, {
    this.system,
    bool? enableSensitiveData,
  }) : enableSensitiveData =
            enableSensitiveData ?? TelemetryHelpers.enableSensitiveDataDefault;

  /// The provider name (e.g. `"openai"`).
  final String? system;

  /// Whether potentially sensitive information (such as file names)
  /// is recorded on spans. Defaults to
  /// [TelemetryHelpers.enableSensitiveDataDefault].
  final bool enableSensitiveData;

  @override
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.filesUploadSpanName,
      arguments: {
        ..._commonArguments('upload'),
        if (mediaType != null) OpenTelemetryConsts.filesMediaTypeKey: mediaType,
        if (enableSensitiveData && fileName != null)
          OpenTelemetryConsts.fileNameKey: fileName,
      },
    );
    try {
      final result = await super.upload(
        content,
        mediaType: mediaType,
        fileName: fileName,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return result;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Stream<List<int>> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    developer.Timeline.startSync(
      OpenTelemetryConsts.filesDownloadSpanName,
      arguments: {
        ..._commonArguments('download'),
        OpenTelemetryConsts.filesIdKey: fileId,
      },
    );
    try {
      yield* super.download(
        fileId,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Future<HostedFileContent?> getFile(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.filesGetSpanName,
      arguments: {
        ..._commonArguments('get_info'),
        OpenTelemetryConsts.filesIdKey: fileId,
      },
    );
    try {
      final result = await super.getFile(
        fileId,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return result;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    developer.Timeline.startSync(
      OpenTelemetryConsts.filesListSpanName,
      arguments: _commonArguments('list'),
    );
    try {
      yield* super.listFiles(
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.filesDeleteSpanName,
      arguments: {
        ..._commonArguments('delete'),
        OpenTelemetryConsts.filesIdKey: fileId,
      },
    );
    try {
      final result = await super.delete(
        fileId,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return result;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  Map<String, Object?> _commonArguments(String operation) => {
        OpenTelemetryConsts.filesOperationNameKey: operation,
        if (system != null) OpenTelemetryConsts.systemKey: system,
      };
}
