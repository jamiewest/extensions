class DeviceIdHelper {
  DeviceIdHelper(Logger logger) : _logger = logger;

  static String? _deviceId;

  final Logger _logger;

  String getDeviceId() {
    var deviceId = getCachedDeviceId();
    if (string.isNullOrWhiteSpace(deviceId)) {
      #pragma warning disable CA1308 // Normalize strings to uppercase.
            // The DevDeviceId must follow the format specified below.
            // 1. The value is a randomly generated Guid/ UUID.
            // 2. The value follows the 8-4-4-4-12 format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            // 3. The value shall be all lowercase and only contain hyphens. No braces or brackets.
            deviceId = Guid.newGuid().toString("D").toLowerInvariant();
      try {
        cacheDeviceId(deviceId);
      } catch (e, s) {
        if (e is Exception) {
          final ex = e as Exception;
          {
            _logger.logWarning(ex, "Failed to cache device ID.");
            // If caching fails, return empty string to avoid reporting a non-cached id.
                deviceId = string.empty;
          }
        } else {
          rethrow;
        }
      }
    }
    return deviceId;
  }

  static String? getCachedDeviceId() {
    if (_deviceId != null) {
      return _deviceId;
    }
    if (RuntimeInformation.isOSPlatform(OSPlatform.windows)) {
      var baseKey = RegistryKey.openBaseKey(RegistryHive.currentUser, RegistryView.registry64);
      var key = baseKey.openSubKey(RegistryKeyPath);
      _deviceId = key?.getValue(RegistryValueName) as string;
    } else if (RuntimeInformation.isOSPlatform(OSPlatform.linux)) {
      var cacheFileDirectoryPath = getCacheFileDirectoryPathForLinux();
      readCacheFile(cacheFileDirectoryPath);
    } else if (RuntimeInformation.isOSPlatform(OSPlatform.osx)) {
      var cacheFileDirectoryPath = getCacheFileDirectoryPathForMacOS();
      readCacheFile(cacheFileDirectoryPath);
    }
    return _deviceId;
    /* TODO: unsupported node kind "unknown" */
    // static void ReadCacheFile(string cacheFileDirectoryPath)
    //         {
      //             string cacheFilePath = Path.Combine(cacheFileDirectoryPath, CacheFileName);
      //             if (File.Exists(cacheFilePath))
      //             {
        //                 _deviceId = File.ReadAllText(cacheFilePath);
        //             }
      //         }
  }

  static void cacheDeviceId(String deviceId) {
    if (RuntimeInformation.isOSPlatform(OSPlatform.windows)) {
      var baseKey = RegistryKey.openBaseKey(RegistryHive.currentUser, RegistryView.registry64);
      var key = baseKey.createSubKey(RegistryKeyPath);
      key.setValue(RegistryValueName, deviceId);
    } else if (RuntimeInformation.isOSPlatform(OSPlatform.linux)) {
      var cacheFileDirectoryPath = getCacheFileDirectoryPathForLinux();
      writeCacheFile(cacheFileDirectoryPath, deviceId);
    } else if (RuntimeInformation.isOSPlatform(OSPlatform.osx)) {
      var cacheFileDirectoryPath = getCacheFileDirectoryPathForMacOS();
      writeCacheFile(cacheFileDirectoryPath, deviceId);
    }
    _deviceId = deviceId;
    /* TODO: unsupported node kind "unknown" */
    // static void WriteCacheFile(string cacheFileDirectoryPath, string deviceId)
    //         {
      //             _ = Directory.CreateDirectory(cacheFileDirectoryPath);
      //             string cacheFilePath = Path.Combine(cacheFileDirectoryPath, CacheFileName);
      //             File.WriteAllText(cacheFilePath, deviceId);
      //         }
  }

  static String getCacheFileDirectoryPathForLinux() {
    if (!RuntimeInformation.isOSPlatform(OSPlatform.linux)) {
      throw invalidOperationException();
    }
    String cacheFileDirectoryPath;
    var xdgCacheHome = Environment.getEnvironmentVariable("XDG_CACHE_HOME");
    if (string.isNullOrWhiteSpace(xdgCacheHome)) {
      var userProfilePath = Environment.getFolderPath(Environment.specialFolder.userProfile);
      cacheFileDirectoryPath = Path.combine(userProfilePath, ".cache");
    } else {
      cacheFileDirectoryPath = Path.combine(xdgCacheHome, "Microsoft", "DeveloperTools");
    }
    return cacheFileDirectoryPath;
  }

  static String getCacheFileDirectoryPathForMacOS() {
    if (!RuntimeInformation.isOSPlatform(OSPlatform.osx)) {
      throw invalidOperationException();
    }
    var userProfilePath = Environment.getFolderPath(Environment.specialFolder.userProfile);
    var cacheFileDirectoryPath = Path.combine(
      userProfilePath,
      "Library",
      "Application Support",
      "Microsoft",
      "DeveloperTools",
    );
    return cacheFileDirectoryPath;
  }
}
