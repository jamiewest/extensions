/// Platform-specific default configuration steps for
/// `DefaultHostApplicationBuilder`.
///
/// Selects a `dart:io`-backed implementation on platforms that have it and a
/// web-safe implementation elsewhere. The IO version loads `appsettings.json`
/// and environment variables; the web version applies neither.
library;

export 'host_application_builder_defaults_web.dart'
    if (dart.library.io) 'host_application_builder_defaults_io.dart';
