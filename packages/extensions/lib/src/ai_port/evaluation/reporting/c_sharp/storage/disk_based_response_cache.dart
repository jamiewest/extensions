import '../../../../open_telemetry_consts.dart';
import '../defaults.dart';
import '../utilities/path_validation.dart';
import 'disk_based_response_cache_cache_entry.dart';

class DiskBasedResponseCache extends DistributedCache {
  DiskBasedResponseCache(
    String storageRootPath,
    String scenarioName,
    String iterationName,
    DateTime Function() provideDateTime,
    {Duration? timeToLiveForCacheEntries = null, },
  ) :
      _scenarioName = scenarioName,
      _iterationName = iterationName,
      _iterationPath = PathValidation.ensureWithinRoot(
            cacheRootPath,
            Path.combine(
              cacheRootPath,
              scenarioName,
              iterationName,
            ) ), _provideDateTime = provideDateTime, _timeToLiveForCacheEntries = timeToLiveForCacheEntries ?? Defaults.defaultTimeToLiveForCacheEntries {
    PathValidation.validatePathSegment(scenarioName, nameof(scenarioName));
    PathValidation.validatePathSegment(iterationName, nameof(iterationName));
    storageRootPath = Path.getFullPath(storageRootPath);
    var cacheRootPath = getCacheRootPath(storageRootPath);
  }

  final String _scenarioName;

  final String _iterationName;

  final String _iterationPath;

  final DateTime Function() _provideDateTime;

  final Duration _timeToLiveForCacheEntries;

  List<int>? getValue(String key) {
    (_, string entryFilePath, string contentsFilePath, bool filesExist) = getPaths(key);
    if (!filesExist) {
      return null;
    }
    var entry = CacheEntry.read(entryFilePath);
    if (entry.expiration <= _provideDateTime()) {
      remove(key);
      return null;
    }
    return File.readAllBytes(contentsFilePath);
  }

  Future<List<int>?> getAsync(String key, {CancellationToken? cancellationToken, }) async  {
    (string _, string entryFilePath, string contentsFilePath, bool filesExist) = getPaths(key);
    if (!filesExist) {
      return null;
    }
    var entry = await CacheEntry.readAsync(
      entryFilePath,
      cancellationToken: cancellationToken,
    ) .configureAwait(false);
    if (entry.expiration <= _provideDateTime()) {
      await removeAsync(key, cancellationToken).configureAwait(false);
      return null;
    }
    var stream = fileStream(
                contentsFilePath,
                FileMode.open,
                FileAccess.read,
                FileShare.read,
                bufferSize: 4096,
                useAsync: true);
    var buffer = List.filled(stream.length, null);
    var totalRead = 0;
    while (totalRead < buffer.length) {
      cancellationToken.throwIfCancellationRequested();
      var read = await stream.readAsync(
                    buffer,
                    offset: totalRead,
                    count: buffer.length - totalRead,
                    cancellationToken).configureAwait(false);
      totalRead += read;
      if (read == 0) {
        if (buffer.length is not 0 && totalRead != buffer.length) {
          throw endOfStreamException(
                        'End of stream reached for ${contentsFilePath} with ${totalRead} bytes read, but ${buffer.length} bytes were expected.');
        } else {
          break;
        }
      }
    }
    return buffer;
  }

  void refresh(String key) {
    (_, string entryFilePath, string contentsFilePath, bool filesExist) = getPaths(key);
    if (!filesExist) {
      throw fileNotFoundException(
                string.format(
                    CultureInfo.currentCulture,
                    EntryAndContentsFilesNotFound,
                    entryFilePath,
                    contentsFilePath));
    }
    var entry = createEntry();
    entry.write(entryFilePath);
  }

  Future refreshAsync(String key, {CancellationToken? cancellationToken, }) async  {
    (_, string entryFilePath, string contentsFilePath, bool filesExist) = getPaths(key);
    if (!filesExist) {
      throw fileNotFoundException(
                string.format(
                    CultureInfo.currentCulture,
                    EntryAndContentsFilesNotFound,
                    entryFilePath,
                    contentsFilePath));
    }
    var entry = createEntry();
    await entry.writeAsync(
      entryFilePath,
      cancellationToken: cancellationToken,
    ) .configureAwait(false);
  }

  void remove(String key) {
    (string keyPath, _, _, _) = getPaths(key);
    Directory.delete(keyPath, recursive: true);
  }

  Future removeAsync(String key, {CancellationToken? cancellationToken, }) {
    remove(key);
    return Task.completedFuture;
  }

  void setValue(String key, List<int> value, DistributedCacheEntryOptions options, ) {
    (string keyPath, string entryFilePath, string contentsFilePath, _) = getPaths(key);
    _ = Directory.createDirectory(keyPath);
    var entry = createEntry();
    entry.write(entryFilePath);
    File.writeAllBytes(contentsFilePath, value);
  }

  Future setAsync(
    String key,
    List<int> value,
    DistributedCacheEntryOptions options,
    {CancellationToken? cancellationToken, },
  ) async  {
    (string keyPath, string entryFilePath, string contentsFilePath, _) = getPaths(key);
    Directory.createDirectory(keyPath);
    var entry = createEntry();
    await entry.writeAsync(
      entryFilePath,
      cancellationToken: cancellationToken,
    ) .configureAwait(false);
    var stream = fileStream(
                contentsFilePath,
                FileMode.create,
                FileAccess.write,
                FileShare.write,
                bufferSize: 4096,
                useAsync: true);
    await stream.writeAsync(value, 0, value.length, cancellationToken).configureAwait(false);
  }

  static void resetStorage(String storageRootPath) {
    var cacheRootPath = getCacheRootPath(storageRootPath);
    Directory.delete(cacheRootPath, recursive: true);
    _ = Directory.createDirectory(cacheRootPath);
  }

  static Future deleteExpiredEntries(
    String storageRootPath,
    DateTime Function() provideDateTime,
    {CancellationToken? cancellationToken, },
  ) async  {
    /* TODO: unsupported node kind "unknown" */
    // static void DeleteDirectoryIfEmpty(string path)
    //         {
      //             if (!Directory.EnumerateFileSystemEntries(path).Any())
      //             {
        //                 Directory.Delete(path, recursive: true);
        //             }
      //         }
    var cacheRootPath = getCacheRootPath(storageRootPath);
    for (final scenarioPath in Directory.getDirectories(cacheRootPath)) {
      cancellationToken.throwIfCancellationRequested();
      for (final iterationPath in Directory.getDirectories(scenarioPath)) {
        cancellationToken.throwIfCancellationRequested();
        for (final keyPath in Directory.getDirectories(iterationPath)) {
          cancellationToken.throwIfCancellationRequested();
          var entryFilePath = getEntryFilePath(keyPath);
          var entry = await CacheEntry.readAsync(
                            entryFilePath,
                            cancellationToken: cancellationToken).configureAwait(false);
          if (entry.expiration <= provideDateTime()) {
            Directory.delete(keyPath, recursive: true);
          }
        }
        deleteDirectoryIfEmpty(iterationPath);
      }
      deleteDirectoryIfEmpty(scenarioPath);
    }
  }

  static String getCacheRootPath(String storageRootPath) {
    return Path.combine(storageRootPath, "cache");
  }

  static String getEntryFilePath(String keyPath) {
    return Path.combine(keyPath, "entry.json");
  }

  static String getContentsFilePath(String keyPath) {
    return Path.combine(keyPath, "contents.data");
  }

  stringkeyPathstringentryFilePathstringcontentsFilePathboolfilesExist getPaths(String key) {
    PathValidation.validatePathSegment(key, nameof(key));
    var keyPath = PathValidation.ensureWithinRoot(
      _iterationPath,
      Path.combine(_iterationPath, key),
    );
    var entryFilePath = getEntryFilePath(keyPath);
    var contentsFilePath = getContentsFilePath(keyPath);
    var contentsFileExists = File.exists(contentsFilePath);
    var entryFileExists = File.exists(entryFilePath);
    if (entryFileExists == contentsFileExists) {
      return (keyPath, entryFilePath, contentsFilePath, filesExist: contentsFileExists);
    } else {
      throw fileNotFoundException(
                contentsFileExists
                    ? string.format(CultureInfo.currentCulture, EntryFileNotFound, entryFilePath)
                    : string.format(
                      CultureInfo.currentCulture,
                      ContentsFileNotFound,
                      contentsFilePath,
                    ) );
    }
  }

  CacheEntry createEntry() {
    var creation = _provideDateTime();
    var expiration = creation.add(_timeToLiveForCacheEntries);
    return cacheEntry(_scenarioName, _iterationName, creation, expiration);
  }
}
