import 'dart:io';

import '../../../../system/threading/cancellation_token.dart';
import '../evaluation_response_cache_provider.dart';
import '../response_cache.dart';
import 'disk_based_response_cache.dart';

/// An [EvaluationResponseCacheProvider] that stores response caches on disk.
class DiskBasedResponseCacheProvider
    implements EvaluationResponseCacheProvider {
  /// Creates a [DiskBasedResponseCacheProvider] rooted at [storageRootPath].
  ///
  /// [_timeToLive] controls how long cached responses remain valid; defaults to
  /// 14 days.
  DiskBasedResponseCacheProvider(
    String storageRootPath, {
    this._timeToLive = const Duration(days: 14),
    this._clock,
  }) : _storageRootPath = Directory(storageRootPath).absolute.path;

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
  Future<void> deleteExpiredCacheEntries({
    CancellationToken? cancellationToken,
  }) async {
    final cacheRoot = Directory(_cacheRootPath);
    if (!cacheRoot.existsSync()) return;

    for (final scenarioDir in cacheRoot.listSync().whereType<Directory>()) {
      for (final iterDir in scenarioDir.listSync().whereType<Directory>()) {
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
