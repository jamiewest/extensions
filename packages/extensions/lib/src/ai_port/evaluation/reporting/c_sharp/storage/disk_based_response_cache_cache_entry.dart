import '../../../../open_telemetry_consts.dart';
import '../json_serialization/json_utilities.dart';

class DiskBasedResponseCache extends DistributedCache {
  DiskBasedResponseCache();

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

  static CacheEntry read(String cacheEntryFilePath) {
    var cacheEntryFile = File.openRead(cacheEntryFilePath);
    var cacheEntry = JsonSerializer.deserialize(
                    cacheEntryFile,
                    JsonUtilities.defaultValue.cacheEntryTypeInfo) ??
                throw jsonException(
                    string.format(
                      CultureInfo.currentCulture,
                      DeserializationFailedMessage,
                      cacheEntryFilePath,
                    ) );
    return cacheEntry;
  }

  static Future<CacheEntry> readAsync(
    String cacheEntryFilePath,
    {CancellationToken? cancellationToken, },
  ) async  {
    var cacheEntryFile = File.openRead(cacheEntryFilePath);
    var cacheEntry = await JsonSerializer.deserializeAsync(
                    cacheEntryFile,
                    JsonUtilities.defaultValue.cacheEntryTypeInfo,
                    cancellationToken).configureAwait(false) ??
                throw jsonException(
                    string.format(
                      CultureInfo.currentCulture,
                      DeserializationFailedMessage,
                      cacheEntryFilePath,
                    ) );
    return cacheEntry;
  }

  void write(String cacheEntryFilePath) {
    var cacheEntryFile = File.create(cacheEntryFilePath);
    JsonSerializer.serialize(cacheEntryFile, this, JsonUtilities.defaultValue.cacheEntryTypeInfo);
  }

  Future writeAsync(String cacheEntryFilePath, {CancellationToken? cancellationToken, }) async  {
    var cacheEntryFile = File.create(cacheEntryFilePath);
    await JsonSerializer.serializeAsync(
                cacheEntryFile,
                this,
                JsonUtilities.defaultValue.cacheEntryTypeInfo,
                cancellationToken).configureAwait(false);
  }
}
