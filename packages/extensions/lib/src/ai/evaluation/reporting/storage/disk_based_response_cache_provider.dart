import 'dart:io';

import 'package:extensions/annotations.dart';

import '../../../../system/threading/cancellation_token.dart';
import '../evaluation_response_cache_provider.dart';
import '../response_cache.dart';
import 'disk_based_response_cache.dart';

/// An [EvaluationResponseCacheProvider] that stores response caches on disk.
@Source(
  name: 'DiskBasedResponseCacheProvider.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting.Storage',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting.Storage/',
)
class DiskBasedResponseCacheProvider implements EvaluationResponseCacheProvider {
  /// Creates a [DiskBasedResponseCacheProvider] rooted at [storageRootPath].
  ///
  /// [timeToLive] controls how long cached responses remain valid; defaults to
  /// 14 days.
  DiskBasedResponseCacheProvider(
    String storageRootPath, {
    Duration timeToLive = const Duration(days: 14),
    DateTime Function()? clock,
  })  : _storageRootPath = Directory(storageRootPath).absolute.path,
        _timeToLive = timeToLive,
        _clock = clock;

  final String _storageRootPath;
  final Duration _timeToLive;
  final DateTime Function()? _clock;

  String get _cacheRootPath =>
      '$_storageRootPath${Platform.pathSeparator}cache';

  @override
  Future<ResponseCache> getCache(
    String scenarioName,
    String iterationName, {
    CancellationToken? cancellationToken,
  }) async {
    _validateSegment(scenarioName, 'scenarioName');
    _validateSegment(iterationName, 'iterationName');
    final sep = Platform.pathSeparator;
    final cacheDir = '$_cacheRootPath$sep$scenarioName$sep$iterationName';
    return DiskBasedResponseCache(
      cacheDir,
      timeToLive: _timeToLive,
      clock: _clock,
    );
  }

  @override
  Future<void> reset({CancellationToken? cancellationToken}) async {
    final dir = Directory(_cacheRootPath);
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  @override
  Future<void> deleteExpiredCacheEntries(
      {CancellationToken? cancellationToken}) async {
    final cacheRoot = Directory(_cacheRootPath);
    if (!cacheRoot.existsSync()) return;

    for (final scenarioDir in cacheRoot.listSync().whereType<Directory>()) {
      for (final iterDir
          in scenarioDir.listSync().whereType<Directory>()) {
        final cache = DiskBasedResponseCache(
          iterDir.path,
          timeToLive: _timeToLive,
          clock: _clock,
        );
        await cache.deleteExpiredEntries();
      }
    }
  }

  static void _validateSegment(String segment, String paramName) {
    if (segment.contains('/') ||
        segment.contains('\\') ||
        segment.contains('..')) {
      throw ArgumentError.value(
        segment,
        paramName,
        'Path segment must not contain "/" or ".."',
      );
    }
  }
}
