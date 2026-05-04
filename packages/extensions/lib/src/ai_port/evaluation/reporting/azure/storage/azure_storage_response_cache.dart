import 'azure_storage_response_cache_cache_entry.dart';

class AzureStorageResponseCache extends DistributedCache {
  AzureStorageResponseCache(
    DataLakeDirectoryClient client,
    String scenarioName,
    String iterationName,
    DateTime Function() provideDateTime,
    {Duration? timeToLiveForCacheEntries = null, },
  ) : _provideDateTime = provideDateTime;

  final String _iterationPath;

  final DateTime Function() _provideDateTime = provideDateTime;

  final Duration _timeToLiveForCacheEntries = timeToLiveForCacheEntries ?? Defaults.DefaultTimeToLiveForCacheEntries;

  List<int>? getValue(String key) {
    (string entryFilePath, string contentsFilePath, bool filesExist) = checkPaths(key);
    if (!filesExist) {
      return null;
    }
    var entry = CacheEntry.read(client.getFileClient(entryFilePath));
    if (entry.expiration <= _provideDateTime()) {
      remove(key);
      return null;
    }
    return client.getFileClient(contentsFilePath).readContent().value.content.toArray();
  }

  Future<List<int>?> getAsync(String key, {CancellationToken? cancellationToken, }) async  {
    (string entryFilePath, string contentsFilePath, bool filesExist) =
            await checkPathsAsync(key, cancellationToken).configureAwait(false);
    if (!filesExist) {
      return null;
    }
    var entry = await CacheEntry.readAsync(
                client.getFileClient(entryFilePath),
                cancellationToken: cancellationToken).configureAwait(false);
    if (entry.expiration <= _provideDateTime()) {
      await removeAsync(key, cancellationToken).configureAwait(false);
      return null;
    }
    var content = await client.getFileClient(contentsFilePath).readContentAsync(cancellationToken).configureAwait(false);
    return content.value.content.toArray();
  }

  void refresh(String key) {
    (string entryFilePath, string contentsFilePath, bool filesExist) = checkPaths(key);
    if (!filesExist) {
      throw fileNotFoundException(
                string.format(
                    CultureInfo.currentCulture,
                    EntryAndContentsFilesNotFound,
                    entryFilePath,
                    contentsFilePath));
    }
    var entryFileClient = client.getFileClient(entryFilePath);
    var entry = createEntry();
    entry.write(entryFileClient);
  }

  Future refreshAsync(String key, {CancellationToken? cancellationToken, }) async  {
    (string entryFilePath, string contentsFilePath, bool filesExist) =
            await checkPathsAsync(key, cancellationToken).configureAwait(false);
    if (!filesExist) {
      throw fileNotFoundException(
                string.format(
                    CultureInfo.currentCulture,
                    EntryAndContentsFilesNotFound,
                    entryFilePath,
                    contentsFilePath));
    }
    var entryClient = client.getFileClient(entryFilePath);
    var entry = createEntry();
    await entry.writeAsync(entryClient, cancellationToken: cancellationToken).configureAwait(false);
  }

  void remove(String key) {
    (string entryFilePath, string contentsFilePath) = getPaths(key);
    var entryClient = client.getFileClient(entryFilePath);
    var contentsClient = client.getFileClient(contentsFilePath);
    _ = entryClient.delete();
    _ = contentsClient.delete();
  }

  Future removeAsync(String key, {CancellationToken? cancellationToken, }) async  {
    (string entryFilePath, _) = getPaths(key);
    var keyDirClient = client.getFileClient(entryFilePath).getParentDirectoryClient();
    _ = await keyDirClient.deleteAsync(
                recursive: true,
                cancellationToken: cancellationToken).configureAwait(false);
  }

  void setValue(String key, List<int> value, DistributedCacheEntryOptions options, ) {
    (string entryFilePath, string contentsFilePath) = getPaths(key);
    var entryClient = client.getFileClient(entryFilePath);
    var contentsClient = client.getFileClient(contentsFilePath);
    var entry = createEntry();
    entry.write(entryClient);
    _ = contentsClient.upload(BinaryData.fromBytes(value).toStream(), overwrite: true);
  }

  Future setAsync(
    String key,
    List<int> value,
    DistributedCacheEntryOptions options,
    {CancellationToken? cancellationToken, },
  ) async  {
    (string entryFilePath, string contentsFilePath) = getPaths(key);
    var entryClient = client.getFileClient(entryFilePath);
    var contentsClient = client.getFileClient(contentsFilePath);
    var entry = createEntry();
    await entry.writeAsync(entryClient, cancellationToken: cancellationToken).configureAwait(false);
    _ = await contentsClient.uploadAsync(
                BinaryData.fromBytes(value).toStream(),
                overwrite: true, cancellationToken).configureAwait(false);
  }

  static Future resetStorage(
    DataLakeDirectoryClient client,
    {CancellationToken? cancellationToken, },
  ) async  {
    _ = await client.deleteIfExistsAsync(
                recursive: true,
                cancellationToken: cancellationToken).configureAwait(false);
  }

  static Future deleteExpiredEntries(
    DataLakeDirectoryClient client,
    DateTime Function() provideDateTime,
    {CancellationToken? cancellationToken, },
  ) async  {
    for (final pathItem in client.getPathsAsync(recursive: true, cancellationToken: cancellationToken).configureAwait(false)) {
      if (pathItem.name.endsWith('/${EntryFileName}', StringComparison.ordinal)) {
        var entryFileClient = client.getParentFileSystemClient().getFileClient(pathItem.name);
        var entry = await CacheEntry.readAsync(
                        entryFileClient,
                        cancellationToken: cancellationToken).configureAwait(false);
        if (entry.expiration <= provideDateTime()) {
          var parentDirectory = entryFileClient.getParentDirectoryClient();
          _ = await parentDirectory.deleteAsync(
                            recursive: true,
                            cancellationToken: cancellationToken).configureAwait(false);
        }
      }
    }
  }

  stringentryFilePathstringcontentsFilePath getPaths(String key) {
    var entryFilePath = '${_iterationPath}/${key}/${EntryFileName}';
    var contentsFilePath = '${_iterationPath}/${key}/${ContentsFileName}';
    return (entryFilePath, contentsFilePath);
  }

  Future<stringentryFilePath, stringcontentsFilePath, boolfilesExist> checkPathsAsync(
    String key,
    CancellationToken cancellationToken,
  ) async  {
    (string entryFilePath, string contentsFilePath) = getPaths(key);
    var entryClient = client.getFileClient(entryFilePath);
    var entryFileExists = await entryClient.existsAsync(cancellationToken).configureAwait(false);
    var contentsClient = client.getFileClient(contentsFilePath);
    var contentsFileExists = await contentsClient.existsAsync(cancellationToken).configureAwait(false);
    if (entryFileExists == contentsFileExists) {
      return (entryFilePath, contentsFilePath, filesExist: contentsFileExists);
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

  stringentryFilePathstringcontentsFilePathboolfilesExist checkPaths(String key) {
    (string entryFilePath, string contentsFilePath) = getPaths(key);
    var entryClient = client.getFileClient(entryFilePath);
    var entryFileExists = entryClient.exists();
    var contentsClient = client.getFileClient(contentsFilePath);
    var contentsFileExists = contentsClient.exists();
    if (entryFileExists == contentsFileExists) {
      return (entryFilePath, contentsFilePath, filesExist: contentsFileExists);
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
    return cacheEntry(scenarioName, iterationName, creation, expiration);
  }
}
