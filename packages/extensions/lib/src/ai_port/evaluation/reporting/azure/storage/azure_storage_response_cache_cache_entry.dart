import '../json_serialization/azure_storage_json_utilities.dart';

class AzureStorageResponseCache extends DistributedCache {
  AzureStorageResponseCache();

}
class CacheEntry {
  const CacheEntry(
    String scenarioName,
    String iterationName,
    DateTime creation,
    DateTime expiration,
  ) :
      scenarioName = scenarioName,
      iterationName = iterationName,
      creation = creation,
      expiration = expiration;

  final String scenarioName = scenarioName;

  final String iterationName = iterationName;

  final DateTime creation = creation;

  final DateTime expiration = expiration;

  static CacheEntry read(DataLakeFileClient fileClient, {CancellationToken? cancellationToken, }) {
    var content = fileClient.readContent(cancellationToken);
    var cacheEntry = JsonSerializer.deserialize(
                    content.value.content.toMemory().span,
                    AzureStorageJsonUtilities.defaultValue.cacheEntryTypeInfo)
                ?? throw jsonException(
                    string.format(
                      CultureInfo.currentCulture,
                      DeserializationFailedMessage,
                      fileClient.name,
                    ) );
    return cacheEntry;
  }

  static Future<CacheEntry> readAsync(
    DataLakeFileClient fileClient,
    {CancellationToken? cancellationToken, },
  ) async  {
    var content = await fileClient.readContentAsync(cancellationToken).configureAwait(false);
    var cacheEntry = await JsonSerializer.deserializeAsync(
                    content.value.content.toStream(),
                    AzureStorageJsonUtilities.defaultValue.cacheEntryTypeInfo,
                    cancellationToken).configureAwait(false)
                ?? throw jsonException(
                    string.format(
                      CultureInfo.currentCulture,
                      DeserializationFailedMessage,
                      fileClient.name,
                    ) );
    return cacheEntry;
  }

  void write(DataLakeFileClient fileClient, {CancellationToken? cancellationToken, }) {
    var stream = new();
    JsonSerializer.serialize(
      stream,
      this,
      AzureStorageJsonUtilities.defaultValue.cacheEntryTypeInfo,
    );
    _ = stream.seek(0, SeekOrigin.begin);
    _ = fileClient.upload(stream, overwrite: true, cancellationToken);
  }

  Future writeAsync(
    DataLakeFileClient fileClient,
    {CancellationToken? cancellationToken, },
  ) async  {
    var stream = new();
    await JsonSerializer.serializeAsync(
                stream,
                this,
                AzureStorageJsonUtilities.defaultValue.cacheEntryTypeInfo,
                cancellationToken).configureAwait(false);
    _ = stream.seek(0, SeekOrigin.begin);
    _ = await fileClient.uploadAsync(
      stream,
      overwrite: true,
      cancellationToken,
    ) .configureAwait(false);
  }
}
