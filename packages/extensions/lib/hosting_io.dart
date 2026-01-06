/// Extends the hosting library with IO-specific functionality for
/// console lifetime management.
///
/// This library adds platform-specific hosting features that depend on
/// dart:io, including console application lifetime management.
///
/// ## Console Lifetime
///
/// Automatically shutdown on SIGTERM/SIGINT signals:
///
/// ```dart
/// final host = createDefaultBuilder(args)
///   ..useConsoleLifetime()
///   .build();
///
/// // Gracefully shuts down on Ctrl+C
/// await host.run();
/// ```
library;

export '../src/hosting/hosting_host_builder_extensions_io.dart'
    hide applyDefaultAppConfiguration;
