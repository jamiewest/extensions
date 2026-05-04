import '../../c_sharp/scenario_run_result.dart';
import '../storage/azure_storage_response_cache_cache_entry.dart';

extension AzureStorageJsonUtilities on JsonSerializerOptions {JsonTypeInfo<T> getTypeInfo<T>() {
return (JsonTypeInfo<T>)options.getTypeInfo(typeof(T));
 }
 }
class Compact {
  Compact();

  static JsonSerializerOptions get options {
    return field ??= createJsonSerializerOptions(writeIndented: false);
  }

  static JsonTypeInfo<CacheEntry> get cacheEntryTypeInfo {
    return options.getTypeInfo<CacheEntry>();
  }

  static JsonTypeInfo<ScenarioRunResult> get scenarioRunResultTypeInfo {
    return options.getTypeInfo<ScenarioRunResult>();
  }
}
class Default {
  Default();

  static JsonSerializerOptions get options {
    return field ??= createJsonSerializerOptions(writeIndented: true);
  }

  static JsonTypeInfo<CacheEntry> get cacheEntryTypeInfo {
    return options.getTypeInfo<CacheEntry>();
  }

  static JsonTypeInfo<ScenarioRunResult> get scenarioRunResultTypeInfo {
    return options.getTypeInfo<ScenarioRunResult>();
  }
}
class JsonContext extends JsonSerializerContext {
  JsonContext();

}
