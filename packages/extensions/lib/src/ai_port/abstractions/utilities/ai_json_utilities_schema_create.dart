/// Provides a collection of utility methods for marshalling JSON data.
extension AJsonUtilities on JsonObject {void insertAtStart(String key, JsonNode value, ) {
#if NET9_0_OR_GREATER
        jsonObject.insert(0, key, value);
#else
        jsonObject.remove(key);
var copiedEntries = System.linq.enumerable.toArray(jsonObject);
jsonObject.clear();
jsonObject.add(key, value);
for (final entry in copiedEntries) {
  jsonObject[entry.key] = entry.value;
}
 }
 }
